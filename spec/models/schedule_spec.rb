# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schedule, type: :model do
  it { is_expected.to belong_to(:child) }
  it { is_expected.to validate_presence_of(:weekday) }
  it { is_expected.to validate_numericality_of(:weekday) }
  it { is_expected.to validate_presence_of(:start_time) }
  it { is_expected.to validate_presence_of(:end_time) }
  it { is_expected.to validate_presence_of(:effective_on) }

  let(:schedule) { build(:schedule) }

  it 'validates effective_on as a date' do
    schedule.update(effective_on: Time.current)
    expect(schedule.valid?).to be_truthy
    schedule.effective_on = "I'm a string"
    expect(schedule.valid?).to be_falsey
    schedule.effective_on = nil
    expect(schedule.valid?).to be_falsey
    schedule.effective_on = '2021-02-01'
    expect(schedule.valid?).to be_truthy
    schedule.effective_on = Date.new(2021, 12, 11)
    expect(schedule.valid?).to be_truthy
  end

  it 'validates expires_on as an optional date' do
    schedule.update(expires_on: Time.current)
    expect(schedule.valid?).to be_truthy
    schedule.expires_on = "I'm a string"
    expect(schedule.valid?).to be_falsey
    schedule.expires_on = nil
    expect(schedule.valid?).to be_truthy
    schedule.expires_on = '2021-02-01'
    expect(schedule.valid?).to be_truthy
    schedule.expires_on = Date.new(2021, 12, 11)
    expect(schedule.valid?).to be_truthy
  end

  it 'validates start_time as a time' do
    schedule.update(start_time: Time.current)
    expect(schedule.valid?).to be_truthy
    schedule.start_time = "I'm a string"
    expect(schedule.valid?).to be_falsey
    schedule.start_time = nil
    expect(schedule.valid?).to be_falsey
    schedule.start_time = '5:00PM'
    expect(schedule.valid?).to be_truthy
    schedule.start_time = Time.new(2007, 11, 1, 15, 25, 0, '+09:00')
    expect(schedule.valid?).to be_truthy
  end

  it 'validates end_time as a time' do
    schedule.update(end_time: Time.current)
    expect(schedule.valid?).to be_truthy
    schedule.end_time = "I'm a string"
    expect(schedule.valid?).to be_falsey
    schedule.end_time = nil
    expect(schedule.valid?).to be_falsey
    schedule.end_time = '5:00PM'
    expect(schedule.valid?).to be_truthy
    schedule.end_time = Time.new(2007, 11, 1, 15, 25, 0, '+09:00')
    expect(schedule.valid?).to be_truthy
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
#  effective_on :date             not null
#  end_time     :time             not null
#  expires_on   :date
#  start_time   :time             not null
#  weekday      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  child_id     :uuid             not null
#
# Indexes
#
#  index_schedules_on_child_id  (child_id)
#  unique_child_schedules       (effective_on,child_id,weekday) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
