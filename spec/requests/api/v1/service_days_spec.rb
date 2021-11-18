# frozen_string_literal: true

require 'rails_helper'

# Since the for_week scope on service_day model uses the Sunday to Friday week range, we should make
# sure we don't work with a Saturday date to avoid flakiness in spec runs. A way to do this is to set
# the week_current_date value to a day that falls within the expected week range

RSpec.describe 'Api::V1::ServiceDays', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:business) { create(:business, user: logged_in_user) }
  let!(:child) { create(:child, business: business) }
  let!(:child_approval) { child.child_approvals.first }
  let!(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }

  let!(:week_current_date) { Time.new(2021, 9, 15, 0, 0, 0, timezone) } # Wednesday
  let!(:week_start_date) { week_current_date.at_beginning_of_week(:sunday) } # Sunday

  let!(:two_weeks_ago_week_current_date) { week_current_date - 2.weeks }
  let!(:two_weeks_ago_week_start_date) { week_start_date - 2.weeks }

  let!(:this_week_service_days) do
    build_list(:attendance, 3) do |attendance|
      attendance.child_approval = child_approval
      attendance.check_in = Helpers
                            .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                            3.hours
      attendance.check_out = Helpers
                             .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                             9.hours + 18.minutes
      attendance.save!
    end.map(&:service_day)
  end

  let!(:past_service_days) do
    [
      create(:attendance, check_in: two_weeks_ago_week_start_date, child_approval: child_approval).service_day,
      create(:attendance, check_in: two_weeks_ago_week_start_date + 2.days, child_approval: child_approval).service_day
    ]
  end

  let!(:extra_service_days) do
    build_list(:attendance, 3) do |attendance|
      attendance.check_in = Helpers
                            .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                            3.hours
      attendance.check_out = Helpers
                             .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                             9.hours + 18.minutes
      attendance.save!
    end.map(&:service_day)
  end

  describe 'GET /api/v1/service_days' do
    include_context 'with correct api version header'

    before do
      travel_to week_current_date
      sign_in logged_in_user
    end

    after { travel_back }

    context 'when sent with a filter date' do
      let(:params) { { filter_date: two_weeks_ago_week_current_date } }

      it 'displays the service_days' do
        get '/api/v1/service_days', params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect do |x|
                 x['child_id']
               end).to match_array(past_service_days.collect(&:child_id))
        expect(parsed_response.collect do |x|
                 x['date']
               end).to match_array(past_service_days.collect(&:date))
        expect(parsed_response.collect do |x|
                 x['tags']
               end).to match_array(past_service_days.collect(&:tags))
        expect(parsed_response.collect do |x|
          x['total_time_in_care']
        end).to match_array(
          past_service_days
          .collect { |service_day| service_day.total_time_in_care.to_s }
        )
        expect(parsed_response.length).to eq(2)
        expect(response).to match_response_schema('service_days')
      end
    end

    context 'when sent without a filter date' do
      it 'displays the service_days' do
        get '/api/v1/service_days', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect do |x|
                 x['child_id']
               end).to match_array(this_week_service_days.collect(&:child_id))
        expect(parsed_response.collect do |x|
                 x['date']
               end).to match_array(this_week_service_days.collect(&:date))
        expect(parsed_response.collect do |x|
                 x['tags']
               end).to match_array(this_week_service_days.collect(&:tags))
        expect(parsed_response.collect do |x|
                 x['total_time_in_care']
               end).to match_array(
                 this_week_service_days
                 .collect { |service_day| service_day.total_time_in_care.to_s }
               )
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('service_days')
      end
    end

    context 'when viewed by an admin' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'displays the service_days' do
        get '/api/v1/service_days', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        all_current_service_days = this_week_service_days + extra_service_days

        expect(parsed_response.collect do |x|
                 x['child_id']
               end).to match_array(all_current_service_days.collect(&:child_id))
        expect(parsed_response.collect do |x|
                 x['date']
               end).to match_array(all_current_service_days.collect(&:date))
        expect(parsed_response.collect do |x|
                 x['tags']
               end).to match_array(all_current_service_days.collect(&:tags))
        expect(parsed_response.collect do |x|
                 x['total_time_in_care']
               end).to match_array(
                 all_current_service_days
                 .collect { |service_day| service_day.total_time_in_care.to_s }
               )
        expect(parsed_response.length).to eq(6)
        expect(response).to match_response_schema('service_days')
      end
    end
  end
end
