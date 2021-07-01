# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  let(:child) { create(:child) }
  let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
  it { should belong_to(:business) }
  it { should have_many(:child_approvals).dependent(:destroy).inverse_of(:child).autosave(true) }
  it { should have_many(:approvals).through(:child_approvals) }
  it { should have_one(:temporary_nebraska_dashboard_case) }

  it { should validate_presence_of(:approvals) }
  it { should validate_presence_of(:date_of_birth) }
  it { should validate_presence_of(:full_name) }

  it 'validates date_of_birth as a date' do
    child.update(date_of_birth: Time.zone.now)
    expect(child.valid?).to be_truthy
    child.date_of_birth = "I'm a string"
    expect(child.valid?).to be_falsey
    child.date_of_birth = nil
    expect(child.valid?).to be_falsey
    child.date_of_birth = '2021-02-01'
    expect(child.valid?).to be_truthy
    child.date_of_birth = Date.new(2021, 12, 11)
    expect(child.valid?).to be_truthy
  end

  it 'validates last_active_date as an optional date' do
    child.update(last_active_date: Time.zone.now)
    expect(child.valid?).to be_truthy
    child.last_active_date = "I'm a string"
    expect(child.valid?).to be_falsey
    child.last_active_date = nil
    expect(child.valid?).to be_truthy
    child.last_active_date = '2021-02-01'
    expect(child.valid?).to be_truthy
    child.last_active_date = Date.new(2021, 12, 11)
    expect(child.valid?).to be_truthy
  end

  it 'validates that inactive_reason is a permitted value only' do
    child.save!

    child.inactive_reason = 'other'
    child.valid?
    expect(child.errors.messages).to eq({})
    expect(child).to be_valid

    child.inactive_reason = 'not a valid reason'
    child.valid?
    expect(child.errors.messages.keys).to eq([:inactive_reason])
    expect(child.errors.messages[:inactive_reason]).to include('is not included in the list')
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:child)).to be_valid
  end

  it { should accept_nested_attributes_for :approvals }
  it { should accept_nested_attributes_for :child_approvals }

  context 'scopes' do
    let(:inactive_child) { create(:child, active: false) }
    let(:deleted_child) { create(:child, deleted: true) }

    it 'only displays active children in the active scope' do
      expect(Child.active).to include(child)
      expect(Child.active).to not_include(inactive_child)
      expect(Child.active).to include(deleted_child)
    end

    it 'only displays children approved for the requested date in the approved_for_date scope' do
      expect(Child.approved_for_date(child.approvals.first.effective_on)).to include(child)
      expect(Child.approved_for_date(child.approvals.first.effective_on)).to include(inactive_child)
      expect(Child.approved_for_date(child.approvals.first.effective_on)).to include(deleted_child)
      expect(Child.approved_for_date(child.approvals.first.effective_on - 1.day)).to eq([])
    end

    it 'displays inactive children but not deleted children in the not_deleted scope' do
      expect(Child.not_deleted).to include(child)
      expect(Child.not_deleted).to include(inactive_child)
      expect(Child.not_deleted).to not_include(deleted_child)
    end
  end

  context 'delegated attributes' do
    it 'gets user from business' do
      expect(child.user).to eq(child.business.user)
    end

    it 'gets state from user' do
      expect(child.state).to eq(child.user.state)
    end

    it 'gets timezone from user' do
      expect(child.timezone).to eq(child.user.timezone)
    end
  end

  describe '#nebraska_hours' do
    context 'using live algorithms' do
      it 'calls the NebraskaHoursCalculator service' do
        calculator_instance = instance_double(NebraskaHoursCalculator)

        allow(Rails.application.config).to receive(:ff_live_algorithms_hours).and_return('true')
        expect(NebraskaHoursCalculator).to receive(:new).with(child, Time.current.to_date).and_return(calculator_instance)
        expect(calculator_instance).to receive(:call)
        child.nebraska_hours(Time.current.to_date)
      end
    end
    context 'using temporary dashboard values' do
      it 'does not call the NebraskaHoursCalculator service' do
        allow(Rails.application.config).to receive(:ff_live_algorithms_hours).and_return('false')
        expect(NebraskaHoursCalculator).not_to receive(:new)
        child.nebraska_hours(Time.current.to_date)
      end
    end
  end

  context 'approval methods' do
    it 'returns an active approval for a specific date' do
      current_approval = child.approvals.first
      expect(child.active_approval(Time.current)).to eq(current_approval)
      expired_approval = create(:approval, effective_on: 3.years.ago, expires_on: 2.years.ago, children: [child])
      expect(child.active_approval(Time.current - 2.years - 6.months)).to eq(expired_approval)
    end

    it 'returns an active child_approval for a specific date' do
      current_child_approval = child.approvals.first.child_approvals.where(child: child).first
      expect(child.active_child_approval(Time.current)).to eq(current_child_approval)
      expired_child_approval = create(:approval, effective_on: 3.years.ago, expires_on: 2.years.ago, children: [child]).child_approvals.where(child: child).first
      expect(child.active_child_approval(Time.current - 2.years - 6.months)).to eq(expired_child_approval)
    end
  end

  context 'attendance methods' do
    it 'returns all attendances regardless of approval date' do
      current_child_approval = child.approvals.first.child_approvals.where(child: child).first
      expired_child_approval = create(:approval, effective_on: 3.years.ago, expires_on: 2.years.ago, children: [child]).child_approvals.where(child: child).first
      current_attendances = create_list(:attendance, 3, child_approval: current_child_approval)
      expired_attendances = create_list(:attendance, 3, child_approval: expired_child_approval)
      expect(child.attendances.pluck(:id)).to match_array(current_attendances.pluck(:id) + expired_attendances.pluck(:id))
    end
  end

  context 'dashboard methods' do
    # TODO
  end

  it 'enqueues a rate association job' do
    include ActiveJob::TestHelper
    ActiveJob::Base.queue_adapter = :test

    child.update!(date_of_birth: (Time.current - 6.years).to_date)
    expect(RateAssociatorJob).to have_been_enqueued.exactly(:twice)
  end

  context 'associates approval with child if applicable' do
    let!(:user) { create(:confirmed_user) }
    let!(:created_business) { create(:business, user: user) }
    let!(:child) do
      create(:child, full_name: 'Parvati Patil',
                     date_of_birth: '2010-04-09',
                     business_id: created_business.id,
                     approvals_attributes: [attributes_for(:approval)])
    end
    let!(:approval) { child.approvals.first }

    context 'child has the same approval as a previous child in our system' do
      let(:new_child_params) do
        {
          full_name: 'Dev Patil',
          date_of_birth: '2015-04-09',
          business_id: created_business.id,
          approvals_attributes: [
            {
              case_number: approval.case_number,
              effective_on: approval.effective_on,
              expires_on: approval.expires_on,
              copay: 20_000,
              copay_frequency: 'monthly'
            }
          ]
        }
      end
      it 'associates the approval' do
        new_child = Child.create! new_child_params
        expect(new_child.approvals.first.id).to eq(approval.id)
      end

      it 'creates a child' do
        expect { Child.create! new_child_params }.to change { Child.count }.by(1)
      end

      it 'does not create an approval' do
        expect { Child.create! new_child_params }.to change { Approval.count }.by(0)
      end

      it 'does create a child approval' do
        expect { Child.create! new_child_params }.to change { ChildApproval.count }.by(1)
      end
    end

    context 'child has a unique approval' do
      let(:new_child_params) do
        {
          full_name: 'Dev Patil',
          date_of_birth: '2015-04-09',
          business_id: created_business.id,
          approvals_attributes: [
            {
              case_number: approval.case_number,
              effective_on: Time.current + 3.months,
              expires_on: approval.expires_on,
              copay: 20_000,
              copay_frequency: 'monthly'
            }
          ]
        }
      end

      it 'does not associate the approval' do
        new_child = Child.create! new_child_params
        expect(new_child.approvals.first.id).to_not eq(approval.id)
      end

      it 'creates a child' do
        expect { Child.create! new_child_params }.to change { Child.count }.by(1)
      end

      it 'creates an approval' do
        expect { Child.create! new_child_params }.to change { Approval.count }.by(1)
      end

      it 'creates a child approval' do
        expect { Child.create! new_child_params }.to change { ChildApproval.count }.by(1)
      end
    end
  end
end

# == Schema Information
#
# Table name: children
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(TRUE), not null
#  date_of_birth      :date             not null
#  deleted            :boolean          default(FALSE), not null
#  enrolled_in_school :boolean
#  full_name          :string           not null
#  inactive_reason    :string
#  last_active_date   :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_id        :uuid             not null
#  dhs_id             :string
#  wonderschool_id    :string
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  unique_children                (full_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
