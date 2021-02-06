# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  it { should belong_to(:business) }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:date_of_birth) }

  it 'factory should be valid (default; no args)' do
    expect(build(:child)).to be_valid
  end

  it 'validates uniqueness of full name' do
    create(:child)
    should validate_uniqueness_of(:full_name).scoped_to(:date_of_birth, :business_id)
  end

  context 'associates the record with a subsidy rule' do
    let!(:date) { Date.current }
    let!(:subsidy_rule_cook_age5) { create(:subsidy_rule_for_illinois, max_age: 5) }
    let!(:subsidy_rule_cook_age3) { create(:subsidy_rule_for_illinois, max_age: 3) }
    let!(:business_cook) { create(:business, county: 'Cook', zipcode: '60606') }
    let!(:child_cook) { create(:child, date_of_birth: Date.current - 2.years, business: business_cook) }
    let!(:subsidy_rule_dupage) { create(:subsidy_rule_for_illinois, county: 'DuPage') }
    let!(:business_dupage) { create(:business, county: 'DuPage', zipcode: '60613') }

    it 'on creation' do
      expect(child_cook.active_subsidy_rule(date)).to eq(subsidy_rule_cook_age3)
    end

    it 'on update' do
      too_old_for_cook = child_cook.date_of_birth - 4.years
      child_cook.update!(date_of_birth: too_old_for_cook)
      expect(child_cook.active_subsidy_rule(date)).to be_nil
      child_cook.update!(date_of_birth: too_old_for_cook + 2.years)
      expect(child_cook.active_subsidy_rule(date)).to eq(subsidy_rule_cook_age5)
      age_eligible_for_dupage = Date.current - Random.rand(1..subsidy_rule_dupage.max_age.to_i - 1).years
      child_cook.update!(business: business_dupage, date_of_birth: age_eligible_for_dupage)
      expect(child_cook.active_subsidy_rule(date)).to eq(subsidy_rule_dupage)
    end
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
              effective_on: Date.current + 3.months,
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
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  business_id   :uuid             not null
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
