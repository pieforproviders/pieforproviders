# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceDay, type: :model do
  let(:service_day) { build(:service_day) }

  it { is_expected.to belong_to(:child) }
  it { is_expected.to validate_presence_of(:date) }

  it 'validates date as a datetime' do
    service_day.update(date: Time.current)
    expect(service_day).to be_valid
    service_day.date = DateTime.new(2021, 12, 11)
    expect(service_day).to be_valid
    service_day.date = '2021-02-01'
    expect(service_day).to be_valid
    service_day.date = Date.new(2021, 12, 11)
    expect(service_day).to be_valid
    service_day.date = "I'm a string"
    expect(service_day).not_to be_valid
    service_day.date = nil
    expect(service_day).not_to be_valid
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:service_day)).to be_valid
  end
end

# == Schema Information
#
# Table name: service_days
#
#  id         :uuid             not null, primary key
#  date       :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :uuid             not null
#
# Indexes
#
#  index_service_days_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
