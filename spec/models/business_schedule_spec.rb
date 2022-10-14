# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessSchedule, type: :model do
  it { is_expected.to belong_to(:business) }
  it { is_expected.to validate_presence_of(:weekday) }
  it { is_expected.to validate_presence_of(:is_open) }
end

# == Schema Information
#
# Table name: business_schedules
#
#  id          :uuid             not null, primary key
#  is_open     :boolean          not null
#  weekday     :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#
# Indexes
#
#  index_business_schedules_on_business_id  (business_id)
#  unique_business_schedules                (business_id,weekday) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
