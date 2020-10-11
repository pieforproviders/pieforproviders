# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'attendances API', type: :request do
  let(:child) { create(:child) }
  let(:attendance_params) do
    {
      "starts_on": Date.current.to_s,
      "check_in": Time.zone.parse((Date.current + 7.hours).to_s).to_s,
      'check_out': Time.zone.parse((Date.current + 20.hours).to_s).to_s,
      "attendance_duration": 'full_day'
    }
  end

  it_behaves_like 'it lists all items for a user', Attendance

  it_behaves_like 'it creates an item', Attendance do
    let(:item_params) { attendance_params }
  end

  it_behaves_like 'it retrieves an item for a user', Attendance do
    let(:item_params) { attendance_params }
  end

  it_behaves_like 'it updates an item', Attendance, 'starts_on', Date.current.to_s, nil do
    let(:item_params) { attendance_params }
  end

  it_behaves_like 'it deletes an item for a user', Attendance do
    let(:item_params) { attendance_params }
  end
end
