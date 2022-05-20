# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  let!(:child) { create(:child) }
  let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }

  it { is_expected.to belong_to(:business) }
  it { is_expected.to have_many(:child_approvals).dependent(:destroy).inverse_of(:child).autosave(true) }
  it { is_expected.to have_many(:approvals).through(:child_approvals) }

  it { is_expected.to validate_presence_of(:approvals) }
  it { is_expected.to validate_presence_of(:date_of_birth) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }

  it 'validates that only one child with the same name and birthdate exist in a business' do
    business = child.business
    duplicate_child = build(
      :child,
      first_name: child.first_name,
      last_name: child.last_name,
      date_of_birth: child.date_of_birth,
      business: business
    )
    expect(duplicate_child).not_to be_valid
    duplicate_child_diff_business = build(
      :child,
      first_name: child.first_name,
      last_name: child.last_name,
      date_of_birth: child.date_of_birth,
      business: create(:business)
    )
    expect(duplicate_child_diff_business).to be_valid
  end

  it 'validates date_of_birth as a date' do
    child.update(date_of_birth: Time.current)
    expect(child).to be_valid
    child.date_of_birth = "I'm a string"
    expect(child).not_to be_valid
    child.date_of_birth = nil
    expect(child).not_to be_valid
    child.date_of_birth = '2021-02-01'
    expect(child).to be_valid
    child.date_of_birth = Date.new(2021, 12, 11)
    expect(child).to be_valid
  end

  it 'validates last_active_date as an optional date' do
    child.update(last_active_date: Time.current)
    expect(child).to be_valid
    child.last_active_date = "I'm a string"
    expect(child).not_to be_valid
    child.last_active_date = nil
    expect(child).to be_valid
    child.last_active_date = '2021-02-01'
    expect(child).to be_valid
    child.last_active_date = Date.new(2021, 12, 11)
    expect(child).to be_valid
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

  it { is_expected.to accept_nested_attributes_for :approvals }
  it { is_expected.to accept_nested_attributes_for :child_approvals }

  describe 'scopes' do
    let(:inactive_child) { create(:child, active: false) }
    let(:deleted_child) { create(:child, deleted_at: Time.current.to_date) }

    it 'only displays active children in the active scope' do
      expect(described_class.active).to include(child)
      expect(described_class.active).to not_include(inactive_child)
      expect(described_class.active).to include(deleted_child)
    end

    it 'only displays children approved for the requested date in the approved_for_date scope' do
      earliest_effective = child.approvals.first.effective_on.at_beginning_of_day
      latest_effective = child.approvals.first.expires_on.at_end_of_day
      expect(described_class.approved_for_date(earliest_effective)).to include(child)
      expect(described_class.approved_for_date(earliest_effective)).to include(inactive_child)
      expect(described_class.approved_for_date(earliest_effective)).to include(deleted_child)
      expect(described_class.approved_for_date(earliest_effective - 1.minute)).to eq([])
      # if it is the child's last day of their approval, it will show them
      expect(described_class.approved_for_date(latest_effective)).to include(child)
      # if it is after the child's last day of their approval, it will not
      expect(described_class.approved_for_date(latest_effective + 1.minute)).to eq([])
    end

    it 'displays inactive children but not deleted children in the not_deleted scope' do
      expect(described_class.not_deleted).to include(child)
      expect(described_class.not_deleted).to include(inactive_child)
      expect(described_class.not_deleted).to not_include(deleted_child)
    end
  end

  describe 'delegated attributes' do
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

  # TODO: this is sloppy and these need to be named better and moved eventually
  describe 'nebraska methods' do
    let(:child) { create(:necc_child) }

    describe '#create_default_schedule' do
      it 'creates default schedules if no schedules_attributes are passed' do
        child.reload
        expect(child.schedules.first.duration).to eq(8.hours)
        expect(child.schedules.first.weekday).to eq(1)
        expect(child.schedules.length).to eq(5)
      end

      it "doesn't create default schedules if schedules_attributes are passed" do
        attrs = attributes_for(:schedule)
        child = create(:necc_child, schedules_attributes: [attrs])
        expect(child.schedules.length).to eq(1)
        expect(child.schedules.first.duration).to eq(attrs[:duration])
      end
    end
  end

  describe 'approval methods' do
    it 'returns an active approval for a specific date' do
      current_approval = child.approvals.first
      expect(child.active_approval(Time.current)).to eq(current_approval)
      expired_approval = create(:approval, effective_on: 3.years.ago, expires_on: 2.years.ago, create_children: false)
      child.approvals << expired_approval
      expect(child.active_approval(2.years.ago - 6.months)).to eq(expired_approval)
    end

    it 'returns an active child_approval for a specific date' do
      current_child_approval = child.approvals.first.child_approvals.where(child: child).first
      expect(child.active_child_approval(Time.current)).to eq(current_child_approval)
      expired_approval = create(:approval, effective_on: 3.years.ago, expires_on: 2.years.ago, create_children: false)
      child.approvals << expired_approval
      expired_child_approval = expired_approval.child_approvals.where(child: child).first
      expect(child.active_child_approval(2.years.ago - 6.months)).to eq(expired_child_approval)
    end
  end

  describe 'attendance methods' do
    it 'returns all attendances regardless of approval date' do
      current_child_approval = child.approvals.first.child_approvals.where(child: child).first
      expired_approval = create(:approval, effective_on: 3.years.ago, expires_on: 2.years.ago, create_children: false)
      child.approvals << expired_approval
      expired_child_approval = expired_approval.child_approvals.where(child: child).first
      current_attendances = create_list(:attendance, 3, child_approval: current_child_approval)
      expired_attendances = create_list(:attendance, 3, child_approval: expired_child_approval)
      expect(child.attendances.pluck(:id))
        .to match_array(current_attendances.pluck(:id) + expired_attendances.pluck(:id))
    end
  end

  it 'enqueues a rate association job' do
    include ActiveJob::TestHelper
    ActiveJob::Base.queue_adapter = :test

    child.update!(date_of_birth: 6.years.ago.to_date)
    expect(RateAssociatorJob).to have_been_enqueued.exactly(:twice)
  end

  describe '#associate_rate' do
    let!(:user) { create(:confirmed_user) }
    let!(:created_business) { create(:business, user: user) }
    let!(:child) do
      create(:child,
             first_name: 'Parvati',
             last_name: 'Patil',
             date_of_birth: '2010-04-09',
             business_id: created_business.id,
             approvals_attributes: [attributes_for(:approval)])
    end
    let!(:approval) { child.approvals.first }

    context 'when the child has the same approval as a previous child in our system' do
      let(:new_child_params) do
        {
          first_name: 'Dev',
          last_name: 'Patil',
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
        new_child = described_class.create! new_child_params
        expect(new_child.approvals.first.id).to eq(approval.id)
      end

      it 'creates a child' do
        expect { described_class.create! new_child_params }.to change(described_class, :count).by(1)
      end

      it 'does not create an approval' do
        expect { described_class.create! new_child_params }.not_to change(Approval, :count)
      end

      it 'does create a child approval' do
        expect { described_class.create! new_child_params }.to change(ChildApproval, :count).by(1)
      end
    end

    context 'when the child has a unique approval' do
      let(:new_child_params) do
        {
          first_name: 'Dev',
          last_name: 'Patil',
          date_of_birth: '2015-04-09',
          business_id: created_business.id,
          approvals_attributes: [
            {
              case_number: approval.case_number,
              effective_on: approval.effective_on + 15.days,
              expires_on: approval.expires_on,
              copay: 20_000,
              copay_frequency: 'monthly'
            }
          ]
        }
      end

      it 'does not associate the approval' do
        new_child = described_class.create! new_child_params
        expect(new_child.approvals.first.id).not_to eq(approval.id)
      end

      it 'creates a child' do
        expect { described_class.create! new_child_params }.to change(described_class, :count).by(1)
      end

      it 'creates an approval' do
        expect { described_class.create! new_child_params }.to change(Approval, :count).by(1)
      end

      it 'creates a child approval' do
        expect { described_class.create! new_child_params }.to change(ChildApproval, :count).by(1)
      end
    end
  end
end
# == Schema Information
#
# Table name: children
#
#  id               :uuid             not null, primary key
#  active           :boolean          default(TRUE), not null
#  date_of_birth    :date             not null
#  deleted_at       :date
#  first_name       :string           not null
#  inactive_reason  :string
#  last_active_date :date
#  last_name        :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  business_id      :uuid             not null
#  dhs_id           :string
#  wonderschool_id  :string
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  index_children_on_deleted_at   (deleted_at)
#  unique_children                (first_name,last_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
