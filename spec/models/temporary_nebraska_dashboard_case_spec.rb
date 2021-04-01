# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TemporaryNebraskaDashboardCase, type: :model do
  it { should belong_to(:child) }

  let(:temporary_nebraska_dashboard_case) { build(:temporary_nebraska_dashboard_case) }

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
