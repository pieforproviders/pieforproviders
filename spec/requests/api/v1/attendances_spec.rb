# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'attendances API', type: :request do
  let(:child) { create(:child) }
  let(:attendance_params) do
    {
      "check_in": Faker::Time.between(from: Time.zone.now - 1.day, to: Time.zone.now).to_s,
      'check_out': Faker::Time.between(from: Time.zone.now, to: Time.zone.now + 1.day).to_s
    }
  end

  it_behaves_like 'it lists all items for a user', Attendance

  it_behaves_like 'it creates an item', Attendance do
    let(:item_params) { attendance_params }
  end

  it_behaves_like 'it retrieves an item for a user', Attendance do
    let(:item_params) { attendance_params }
  end

  it_behaves_like 'it updates an item', Attendance, 'check_in', Faker::Time.between(from: Time.zone.now - 2.days, to: Time.zone.now - 1.day).to_s, 'A', true do
    let(:item_params) { attendance_params }
  end

  it_behaves_like 'it deletes an item for a user', Attendance do
    let(:item_params) { attendance_params }
  end
end
