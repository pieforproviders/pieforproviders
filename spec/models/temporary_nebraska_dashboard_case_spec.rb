# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TemporaryNebraskaDashboardCase, type: :model do
  let(:temporary_nebraska_dashboard_case) { build(:temporary_nebraska_dashboard_case) }

  it { is_expected.to belong_to(:child) }
  it { is_expected.to validate_presence_of(:absences) }
  it { is_expected.to validate_presence_of(:attendance_risk) }
  it { is_expected.to validate_presence_of(:earned_revenue) }
  it { is_expected.to validate_presence_of(:estimated_revenue) }
  it { is_expected.to validate_presence_of(:full_days) }
  it { is_expected.to validate_presence_of(:hours) }

  it 'factory should be valid (default; no args)' do
    expect(build(:temporary_nebraska_dashboard_case)).to be_valid
  end
end

# == Schema Information
#
# Table name: temporary_nebraska_dashboard_cases
#
#  id                :uuid             not null, primary key
#  absences          :text
#  as_of             :string
#  attendance_risk   :text
#  deleted_at        :date
#  earned_revenue    :text
#  estimated_revenue :text
#  family_fee        :decimal(, )
#  full_days         :text
#  hours             :text
#  hours_attended    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  child_id          :uuid             not null
#
# Indexes
#
#  index_temporary_nebraska_dashboard_cases_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
