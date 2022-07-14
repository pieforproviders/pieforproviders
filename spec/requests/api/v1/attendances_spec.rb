# frozen_string_literal: true

require 'rails_helper'

# Since the for_week scope on attendance model uses the Sunday to Friday week range, we should make
# sure we don't work with a Saturday date to avoid flakiness in spec runs. A way to do this is to set
# the week_current_date value to a day that falls within the expected week range

RSpec.describe 'Api::V1::Attendances', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:business) { create(:business, user: logged_in_user) }
  let!(:child) do
    create(:child, business: business, effective_date: '2021-9-15'.in_time_zone(logged_in_user.timezone) - 2.months)
  end

  let!(:week_current_date) { '2021-9-15'.in_time_zone(child.timezone) } # Wednesday
  let!(:week_start_date) { week_current_date.at_beginning_of_week(:sunday) + 1.day + 11.hours } # Monday

  let!(:two_weeks_ago_week_current_date) { week_current_date - 2.weeks }
  let!(:two_weeks_ago_week_start_date) { week_start_date - 2.weeks }

  let!(:this_week_attendances) do
    service_days = []
    3.times do |idx|
      check_in_date = week_start_date + idx.days
      service_day = create(:service_day, date: check_in_date.at_beginning_of_day, child: child)
      service_days << service_day
      create(:attendance,
             check_in: check_in_date + 3.hours,
             child_approval: child.child_approvals.first,
             service_day: service_day)
    end
    perform_enqueued_jobs
    service_days.each(&:reload).map(&:attendances).flatten
  end

  let!(:past_attendances) do
    service_days = []
    2.times do |idx|
      check_in_date = two_weeks_ago_week_start_date + idx.days
      service_day = create(:service_day, date: check_in_date.at_beginning_of_day, child: child)
      service_days << service_day
      create(:attendance,
             check_in: check_in_date + 3.hours,
             child_approval: child.child_approvals.first,
             service_day: service_day)
    end
    perform_enqueued_jobs
    service_days.each(&:reload).map(&:attendances).flatten
  end

  let!(:extra_attendances) do
    service_days = []
    3.times do |idx|
      check_in_date = week_start_date + idx.days
      service_day = create(:service_day, date: check_in_date.at_beginning_of_day)
      service_days << service_day
      create(:attendance,
             check_in: check_in_date + 3.hours,
             child_approval: service_day.child.child_approvals.first,
             service_day: service_day)
    end
    perform_enqueued_jobs
    service_days.each(&:reload).map(&:attendances).flatten
  end

  describe 'GET /api/v1/attendances' do
    include_context 'with correct api version header'

    before do
      travel_to week_current_date
      sign_in logged_in_user
    end

    after { travel_back }

    context 'when sent with a filter date' do
      let(:params) { { filter_date: two_weeks_ago_week_current_date } }

      it 'displays the attendances' do
        get '/api/v1/attendances', params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect do |x|
                 x['child_approval_id']
               end).to match_array(past_attendances.collect(&:child_approval_id))
        expect(parsed_response.collect do |x|
          x['time_in_care']
        end).to match_array(past_attendances.collect { |x| x.time_in_care.to_s })
        expect(parsed_response.length).to eq(2)
        expect(response).to match_response_schema('attendances')
      end
    end

    context 'when sent without a filter date' do
      it 'displays the attendances' do
        get '/api/v1/attendances', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect do |x|
                 x['child_approval_id']
               end).to match_array(this_week_attendances.collect(&:child_approval_id))
        expect(parsed_response.collect do |x|
                 x['time_in_care']
               end).to match_array(this_week_attendances.collect { |x| x.time_in_care.to_s })
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('attendances')
      end
    end

    context 'when viewed by an admin' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'displays the attendances' do
        get '/api/v1/attendances', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        all_current_attendances = this_week_attendances + extra_attendances
        expect(parsed_response.collect do |x|
                 x['child_approval_id']
               end).to match_array(all_current_attendances.collect(&:child_approval_id))
        expect(parsed_response.collect do |x|
                 x['time_in_care']
               end).to match_array(all_current_attendances.collect { |x| x.time_in_care.to_s })
        expect(parsed_response.length).to eq(6)
        expect(response).to match_response_schema('attendances')
      end
    end
  end

  describe 'PUT /api/v1/attendance/:id' do
    include_context 'with correct api version header'

    let!(:attendance) { past_attendances.select { |attendance| attendance.check_in.wday.between?(1, 5) }.first }
    let!(:new_check_in) { attendance.check_in + 1.hour }
    let!(:new_check_out) { attendance.check_in + 6.hours }

    before { ServiceDay.all.reload }

    context 'when logged in as a non-admin user' do
      before do
        sign_in logged_in_user
      end

      it 'can submit a new check_in for an attendance' do
        check_in_params = { attendance: { check_in: new_check_in.to_s } }
        put "/api/v1/attendances/#{attendance.id}", params: check_in_params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(DateTime.parse(parsed_response['check_in'])).to eq(DateTime.parse(new_check_in.to_s))
      end

      it 'can submit a new check_out for an attendance' do
        check_out_params = { attendance: { check_out: new_check_out.to_s } }
        put "/api/v1/attendances/#{attendance.id}", params: check_out_params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(DateTime.parse(parsed_response['check_out'])).to eq(DateTime.parse(new_check_out.to_s))
      end

      it 'can change an attendance to an absence' do
        check_in = attendance.check_in
        check_out = attendance.check_out
        absence_params = { attendance: { service_day_attributes: { absence_type: 'absence' } } }
        create(:schedule, child: child, effective_on: new_check_in - 2.days, weekday: new_check_in.wday)
        put "/api/v1/attendances/#{attendance.id}", params: absence_params, headers: headers
        parsed_response = JSON.parse(response.body)
        attendance.reload
        expect(DateTime.parse(parsed_response['check_in']))
          .to eq(DateTime.parse(check_in.in_time_zone(child.timezone).to_s))
        expect(DateTime.parse(parsed_response['check_out']))
          .to eq(DateTime.parse(check_out.in_time_zone(child.timezone).to_s))
        expect(attendance.service_day.absence_type).to eq('absence_on_scheduled_day')
      end

      it "cannot update a different user's attendance" do
        different_user = create(:confirmed_user)
        sign_in different_user
        check_in_params = { attendance: { check_in: new_check_in.to_s } }
        put "/api/v1/attendances/#{attendance.id}", params: check_in_params, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as an admin user' do
      let!(:admin_user) { create(:confirmed_user, admin: true) }
      let(:params) do
        {
          attendance: {
            check_in: new_check_in.to_s,
            check_out: new_check_out.to_s,
            service_day_attributes: { absence_type: 'absence' }
          }
        }
      end

      before do
        sign_in admin_user
      end

      it 'can submit a new check_in for an attendance' do
        check_in_params = { attendance: { check_in: new_check_in.to_s } }
        put "/api/v1/attendances/#{attendance.id}", params: check_in_params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(DateTime.parse(parsed_response['check_in'])).to eq(DateTime.parse(new_check_in.to_s))
      end

      it 'can submit a new check_out for an attendance' do
        check_out_params = { attendance: { check_out: new_check_out.to_s } }
        put "/api/v1/attendances/#{attendance.id}", params: check_out_params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(DateTime.parse(parsed_response['check_out'])).to eq(DateTime.parse(new_check_out.to_s))
      end

      it 'can change an attendance to an absence' do
        check_in = attendance.check_in
        check_out = attendance.check_out
        absence_params = { attendance: { service_day_attributes: { absence_type: 'absence' } } }
        create(:schedule, child: child, effective_on: new_check_in - 2.days, weekday: new_check_in.wday)
        put "/api/v1/attendances/#{attendance.id}", params: absence_params, headers: headers
        parsed_response = JSON.parse(response.body)
        attendance.reload
        expect(DateTime.parse(parsed_response['check_in']))
          .to eq(DateTime.parse(check_in.in_time_zone(child.timezone).to_s))
        expect(DateTime.parse(parsed_response['check_out']))
          .to eq(DateTime.parse(check_out.in_time_zone(child.timezone).to_s))
        expect(attendance.service_day.absence_type).to eq('absence_on_scheduled_day')
      end
    end
  end

  describe 'DELETE /api/v1/attendance/:id' do
    include_context 'with correct api version header'

    let(:attendance) { past_attendances.first }

    context 'when logged in as a non-admin user' do
      before do
        sign_in logged_in_user
      end

      it 'can delete an attendance in its own user account' do
        delete "/api/v1/attendances/#{attendance.id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end

      it "cannot update a different user's attendance" do
        different_user = create(:confirmed_user)
        sign_in different_user
        delete "/api/v1/attendances/#{attendance.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as an admin user' do
      let!(:admin_user) { create(:confirmed_user, admin: true) }

      before do
        sign_in admin_user
      end

      it 'can delete a non-admin attendance' do
        delete "/api/v1/attendances/#{attendance.id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
