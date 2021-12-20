# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schedule, type: :model do
  let(:schedule) { build(:schedule) }

  it { is_expected.to belong_to(:child) }
  it { is_expected.to validate_presence_of(:weekday) }
  it { is_expected.to validate_numericality_of(:weekday) }
  it { is_expected.to validate_presence_of(:duration) }
  it { is_expected.to validate_presence_of(:effective_on) }

  it 'validates effective_on as a date' do
    schedule.update(effective_on: Time.current)
    expect(schedule).to be_valid
    schedule.effective_on = "I'm a string"
    expect(schedule).not_to be_valid
    schedule.effective_on = nil
    expect(schedule).not_to be_valid
    schedule.effective_on = '2021-02-01'
    expect(schedule).to be_valid
    schedule.effective_on = Date.new(2021, 12, 11)
    expect(schedule).to be_valid
  end

  it 'validates expires_on as an optional date' do
    schedule.update(expires_on: Time.current)
    expect(schedule).to be_valid
    schedule.expires_on = "I'm a string"
    expect(schedule).not_to be_valid
    schedule.expires_on = nil
    expect(schedule).to be_valid
    schedule.expires_on = '2021-02-01'
    expect(schedule).to be_valid
    schedule.expires_on = Date.new(2021, 12, 11)
    expect(schedule).to be_valid
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:schedule)).to be_valid
    expect(build(:schedule, :expires)).to be_valid
  end
end

# == Schema Information
#
# Table name: schedules
#
#  id           :uuid             not null, primary key
#  deleted_at   :date
#  duration     :interval
#  effective_on :date             not null
#  expires_on   :date
#  weekday      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  child_id     :uuid             not null
#
# Indexes
#
#  index_schedules_on_child_id      (child_id)
#  index_schedules_on_effective_on  (effective_on)
#  index_schedules_on_expires_on    (expires_on)
#  index_schedules_on_updated_at    (updated_at)
#  index_schedules_on_weekday       (weekday)
#  unique_child_schedules           (effective_on,child_id,weekday) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
