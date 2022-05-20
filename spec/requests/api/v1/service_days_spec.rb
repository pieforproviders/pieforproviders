# frozen_string_literal: true

require 'rails_helper'

# Since the for_week scope on service_day model uses the Sunday to Friday week range, we should make
# sure we don't work with a Saturday date to avoid flakiness in spec runs. A way to do this is to set
# the week_current_date value to a day that falls within the expected week range

RSpec.describe 'Api::V1::ServiceDays', type: :request do
  let!(:logged_in_user) { create(:confirmed_user, :nebraska) }
  let!(:business) { create(:business, :nebraska_ldds, user: logged_in_user) }
  let!(:child) { create(:child, last_name: 'zzzz', business: business) }
  let!(:child_approval) { child.child_approvals.first }
  let!(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }

  let!(:week_current_date) { Time.new(2021, 9, 15, 0, 0, 0, timezone) } # Wednesday
  let!(:week_start_date) { week_current_date.in_time_zone(child.timezone).at_beginning_of_week(:sunday) } # Sunday

  let!(:two_weeks_ago_week_current_date) { week_current_date - 2.weeks }
  let!(:two_weeks_ago_week_start_date) { week_start_date - 2.weeks }

  let!(:this_week_service_days) do
    service_days = build_list(:attendance, 3) do |attendance|
      attendance.child_approval = child_approval
      attendance.check_in = Helpers
                            .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                            3.hours
      attendance.check_out = Helpers
                             .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                             9.hours + 18.minutes
      attendance.save!
    end.map(&:service_day)
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  let!(:past_service_days) do
    service_days = [
      create(:attendance, check_in: two_weeks_ago_week_start_date, child_approval: child_approval).service_day,
      create(:attendance, check_in: two_weeks_ago_week_start_date + 2.days, child_approval: child_approval).service_day
    ]
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  let!(:another_user_service_days) do
    service_days = build_list(:attendance, 3) do |attendance|
      attendance.child_approval = create(:child_approval,
                                         child: create(:child, business: create(:business, :nebraska_ldds)))
      attendance.check_in = Helpers
                            .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                            3.hours
      attendance.check_out = Helpers
                             .next_attendance_day(child_approval: child_approval, date: week_start_date) +
                             9.hours + 18.minutes
      attendance.save!
    end.map(&:service_day)
    perform_enqueued_jobs
    service_days.each(&:reload)
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

    context 'when a service day has no attendances' do
      before { Attendance.all.destroy_all }

      it 'displays the service days with empty attendances' do
        get '/api/v1/service_days', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.map { |pr| pr['attendances'] }.compact_blank).to be_empty
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
        all_current_service_days = this_week_service_days + another_user_service_days

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

      it 'displays the service_days in order by child last name' do
        get '/api/v1/service_days', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.last['child']['last_name']).to eq('zzzz')
      end
    end
  end

  describe 'POST /api/v1/service_days' do
    include_context 'with correct api version header'

    let(:params_without_child_id) do
      {
        service_day: {
          date: Time.current.in_time_zone(child.timezone).to_date.to_s
        }
      }
    end

    let(:params_with_child_id) do
      {
        service_day: {
          date: Time.current.in_time_zone(child.timezone).to_date.to_s,
          child_id: child.id
        }
      }
    end

    let(:params_with_absence) do
      {
        service_day: {
          date: Time.current.in_time_zone(child.timezone).to_date.to_s,
          child_id: child.id,
          absence_type: 'absence'
        }
      }
    end

    let(:params_with_bad_absence_reason) do
      {
        service_day: {
          date: Time.current.in_time_zone(child.timezone).to_date.to_s,
          child_id: child.id,
          absence_type: 'not-an-absence'
        }
      }
    end

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it 'creates a service_day for the child' do
        post '/api/v1/service_days', params: params_with_child_id, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['child_id']).to eq(child.id)
        expect(child.reload.service_days.pluck(:date))
          .to include(Time.current.to_date.in_time_zone(child.timezone).at_beginning_of_day)
        expect(response).to match_response_schema('service_day')
        expect(response.status).to eq(201)
      end

      it 'does not create a service_day without a child id' do
        post '/api/v1/service_days', params: params_without_child_id, headers: headers
        expect(response.status).to eq(422)
      end

      it 'does not create a service_day with a bad absence type' do
        post '/api/v1/service_days', params: params_with_bad_absence_reason, headers: headers
        expect(response.status).to eq(422)
      end

      it 'creates an absence for the child' do
        post '/api/v1/service_days', params: params_with_absence, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['child_id']).to eq(child.id)
        expect(parsed_response['absence_type']).to eq(params_with_absence[:service_day][:absence_type])
        expect(child.reload.service_days.pluck(:date))
          .to include(Time.current.to_date.in_time_zone(child.timezone).at_beginning_of_day)
        expect(response).to match_response_schema('service_day')
        expect(response.status).to eq(201)
      end
    end

    context 'when logged in as an admin user' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'creates a service_day for the child' do
        post '/api/v1/service_days', params: params_with_child_id, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['child_id']).to eq(child.id)
        expect(child.reload.service_days.pluck(:date))
          .to include(Time.current.to_date.in_time_zone(child.timezone).at_beginning_of_day)
        expect(response).to match_response_schema('service_day')
        expect(response.status).to eq(201)
      end

      it 'does not create a service_day without a child id' do
        post '/api/v1/service_days', params: params_without_child_id, headers: headers
        expect(response.status).to eq(422)
      end

      it 'does not create a service_day with a bad absence type' do
        post '/api/v1/service_days', params: params_with_bad_absence_reason, headers: headers
        expect(response.status).to eq(422)
      end

      it 'creates an absence for the child' do
        post '/api/v1/service_days', params: params_with_absence, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['child_id']).to eq(child.id)
        expect(parsed_response['absence_type']).to eq(params_with_absence[:service_day][:absence_type])
        expect(child.reload.service_days.pluck(:date))
          .to include(Time.current.in_time_zone(child.timezone).at_beginning_of_day)
        expect(response).to match_response_schema('service_day')
        expect(response.status).to eq(201)
      end
    end
  end
end
