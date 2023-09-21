# frozen_string_literal: true

require 'rails_helper'

# Since the for_week scope on service_day model uses the Sunday to Friday week range, we should make
# sure we don't work with a Saturday date to avoid flakiness in spec runs. A way to do this is to set
# the week_current_date value to a day that falls within the expected week range

RSpec.describe 'Api::V1::ServiceDays' do
  let!(:state) do
    create(:state)
  end
  # rubocop:disable RSpec/LetSetup
  let!(:state_time_rules) do
    [
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      ),
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      ),
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (24 * 3600)
      )
    ]
  end
  # rubocop:enable RSpec/LetSetup

  let!(:logged_in_user) { create(:confirmed_user, :nebraska) }
  let!(:business) { create(:business, :nebraska_ldds, user: logged_in_user) }
  let!(:user_second_business) { create(:business, :nebraska_ldds, user: logged_in_user) }
  let!(:other_business) { create(:business, :nebraska_ldds) }
  let!(:child) do
    create(
      :child,
      last_name: 'zzzz',
      business:,
      effective_date: '2021-09-15'.in_time_zone(logged_in_user.timezone) - 3.months
    )
  end
  let!(:child_approval) { child.child_approvals.first }
  let!(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }

  let!(:week_current_date) { Time.new(2021, 9, 15, 0, 0, 0, timezone) } # Wednesday
  let!(:week_start_date) { week_current_date.in_time_zone(child.timezone).at_beginning_of_week(:sunday) } # Sunday

  let!(:two_weeks_ago_week_current_date) { week_current_date - 2.weeks }
  let!(:two_weeks_ago_week_start_date) { week_start_date - 2.weeks }

  let!(:this_week_service_days) do
    service_days = []
    3.times do |idx|
      date = Helpers.next_attendance_day(
        child_approval:,
        date: week_start_date + idx.days
      )
      service_day = create(:service_day, child:, date: date.at_beginning_of_day)
      service_days << service_day
      create(
        :attendance,
        check_in: date + 3.hours,
        check_out: date + 9.hours + 18.minutes,
        child_approval:,
        service_day:
      )
    end
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  let!(:past_service_days) do
    service_days = []
    2.times do |idx|
      date = two_weeks_ago_week_start_date + idx.days
      service_day = create(:service_day, child:, date: date.at_beginning_of_day)
      service_days << service_day
      create(
        :attendance,
        check_in: date + 3.hours,
        check_out: date + 9.hours + 18.minutes,
        child_approval:,
        service_day:
      )
    end
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  let!(:user_second_business_service_days) do
    child = create(
      :child,
      business: user_second_business,
      effective_date: '2021-09-15'.in_time_zone(logged_in_user.timezone) - 3.months
    )
    child_approval = child.child_approvals.first
    service_days = []
    3.times do |idx|
      date = Helpers.next_attendance_day(
        child_approval:,
        date: week_start_date + idx.days
      )
      service_day = create(:service_day, child:, date: date.at_beginning_of_day)
      service_days << service_day
      create(
        :attendance,
        check_in: date + 3.hours,
        check_out: date + 9.hours + 18.minutes,
        child_approval:,
        service_day:
      )
    end
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  let!(:user_second_business_past_service_days) do
    child = create(
      :child,
      business: user_second_business,
      effective_date: '2021-09-15'.in_time_zone(logged_in_user.timezone) - 3.months
    )
    child_approval = child.child_approvals.first
    service_days = []
    3.times do |idx|
      date = two_weeks_ago_week_start_date + idx.days
      service_day = create(:service_day, child:, date: date.at_beginning_of_day)
      service_days << service_day
      create(
        :attendance,
        check_in: date + 3.hours,
        check_out: date + 9.hours + 18.minutes,
        child_approval:,
        service_day:
      )
    end
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  let!(:another_user_service_days) do
    child = create(
      :child,
      business: other_business,
      effective_date: '2021-09-15'.in_time_zone(other_business.user.timezone) - 3.months
    )
    child_approval = child.child_approvals.first
    service_days = []
    3.times do |idx|
      date = Helpers.next_attendance_day(
        child_approval:,
        date: week_start_date + idx.days
      )
      service_day = create(:service_day, child:, date: date.at_beginning_of_day)
      service_days << service_day
      create(
        :attendance,
        check_in: date + 3.hours,
        check_out: date + 9.hours + 18.minutes,
        child_approval:,
        service_day:
      )
    end
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  let!(:another_user_past_service_days) do
    child = create(
      :child,
      business: other_business,
      effective_date: '2021-09-15'.in_time_zone(other_business.user.timezone) - 3.months
    )
    child_approval = child.child_approvals.first
    service_days = []
    3.times do |idx|
      date = two_weeks_ago_week_start_date + idx.days
      service_day = create(:service_day, child:, date: date.at_beginning_of_day)
      service_days << service_day
      create(
        :attendance,
        check_in: date + 3.hours,
        check_out: date + 9.hours + 18.minutes,
        child_approval:,
        service_day:
      )
    end
    perform_enqueued_jobs
    service_days.each(&:reload)
  end

  describe 'GET /api/v1/service_days/::id' do
    include_context 'with correct api version header'
    context 'when logged in as an admin' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'gets the service day by id' do
        get("/api/v1/service_days/#{business.children.first.service_days.first.id}", params: {}, headers:)
        expect(response).to match_response_schema('service_day')
        parsed_response = response.parsed_body
        expect(parsed_response['id']).to eq(business.children.first.service_days.first.id)
      end

      it 'returns an error if the service day does not exist' do
        service_day = business.children.first.service_days.first
        service_day.destroy
        get("/api/v1/service_days/#{service_day.id}", params: {}, headers:)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as a non-admin' do
      before { sign_in logged_in_user }

      it 'gets the service day by id' do
        get("/api/v1/service_days/#{business.children.first.service_days.first.id}", params: {}, headers:)
        expect(response).to match_response_schema('service_day')
        parsed_response = response.parsed_body
        expect(parsed_response['id']).to eq(business.children.first.service_days.first.id)
      end

      it 'returns an error if the service day does not exist' do
        service_day = business.children.first.service_days.first
        service_day.destroy
        get("/api/v1/service_days/#{service_day.id}", params: {}, headers:)
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if the service day is not within the scope of the user' do
        get("/api/v1/service_days/#{other_business.children.first.service_days.first.id}", params: {}, headers:)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT /api/v1/service_days' do
    include_context 'with correct api version header'
    context 'when logged in as a non admin user' do
      before do
        sign_in logged_in_user
        business.reload
      end

      it 'returns nothing if service day does not exist' do
        to_be_deleted = create(:service_day)
        params = { service_day: { absence_type: 'absence' } }
        to_be_deleted.destroy
        put("/api/v1/service_days/#{to_be_deleted.id}", params:, headers:)
        expect(response).to have_http_status(:not_found)
      end

      it 'returns nothing if service day is not within the scope of the user' do
        unscoped_service_day = other_business.children.first.service_days.first
        params = { service_day: { absence_type: 'absence' } }
        put("/api/v1/service_days/#{unscoped_service_day.id}", params:, headers:)
        expect(response).to have_http_status(:not_found)
      end

      it 'updates service day if service day is within scope of the user' do
        scoped_service_day = business.children.first.service_days.select do |x|
          [1, 2, 3, 4, 5].include? x.date.to_date.cwday
        end.first
        params = { service_day: { absence_type: 'absence' } }
        put("/api/v1/service_days/#{scoped_service_day.id}", params:, headers:)
        resp = response.parsed_body
        expect(resp['absence_type']).to eq('absence_on_scheduled_day')
      end
    end

    context 'when logged in as an admin user' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'returns nothing if service day does not exist' do
        to_be_deleted = create(:service_day)
        params = { service_day: { absence_type: 'absence' } }
        to_be_deleted.destroy
        put("/api/v1/service_days/#{to_be_deleted.id}", params:, headers:)
        expect(response).to have_http_status(:not_found)
      end

      it 'updates any service_day' do
        unscoped_service_day = other_business.children.first.service_days.select do |x|
          [1, 2, 3, 4, 5].include? x.date.to_date.cwday
        end.first
        params = { service_day: { absence_type: 'absence' } }
        put("/api/v1/service_days/#{unscoped_service_day.id}", params:, headers:)
        resp = response.parsed_body
        expect(resp['absence_type']).to eq('absence_on_scheduled_day')
      end
    end
  end

  describe 'DELETE /api/v1/service_days' do
    include_context 'with correct api version header'
    context 'when logged in as a non admin user' do
      before do
        sign_in logged_in_user
      end

      it 'returns 404 if service day does not exist' do
        to_be_deleted = create(:service_day)
        to_be_deleted.destroy
        delete("/api/v1/service_days/#{to_be_deleted.id}", params: {}, headers:)
        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 if service day is not within the scope of the user' do
        unscoped_service_day = other_business.children.first.service_days.first
        delete("/api/v1/service_days/#{unscoped_service_day.id}", params: {}, headers:)
        expect(response).to have_http_status(:not_found)
      end

      it 'can delete a service day in the user\'s account' do
        scoped_service_day = business.children.first.service_days.first
        delete("/api/v1/service_days/#{scoped_service_day.id}", params: {}, headers:)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when logged in as an admin user' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'can delete a service day in any account' do
        unscoped_service_day = other_business.children.first.service_days.first
        delete("/api/v1/service_days/#{unscoped_service_day.id}", params: {}, headers:)
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'GET /api/v1/service_days' do
    include_context 'with correct api version header'

    before { travel_to week_current_date }

    after { travel_back }

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it 'displays the service days with empty attendances if none exist' do
        Attendance.destroy_all
        get('/api/v1/service_days', params: {}, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('attendances').compact_blank).to be_empty
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with a filter date' do
        params = { filter_date: two_weeks_ago_week_current_date }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(past_service_days.collect(&:child_id) +
          user_second_business_past_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(past_service_days.collect(&:date) + user_second_business_past_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(past_service_days.collect(&:tags) + user_second_business_past_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(past_service_days.collect do |service_day|
                            service_day.total_time_in_care.to_s
                          end + user_second_business_past_service_days.collect do |service_day|
                                  service_day.total_time_in_care.to_s
                                end)
        expect(parsed_response.length).to eq(5)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with a business id' do
        params = { business: [user_second_business.id] }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(user_second_business_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(user_second_business_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(user_second_business_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(
            user_second_business_service_days.collect { |service_day| service_day.total_time_in_care.to_s }
          )
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with multiple business ids' do
        params = { business: [business.id, user_second_business.id] }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id').uniq)
          .to match_array(
            [
              *this_week_service_days.collect(&:child_id),
              *user_second_business_service_days.collect(&:child_id)
            ].uniq
          )
        expect(parsed_response.pluck('date'))
          .to match_array(this_week_service_days.collect(&:date) + user_second_business_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(this_week_service_days.collect(&:tags) + user_second_business_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(this_week_service_days.collect do |service_day|
                            service_day.total_time_in_care.to_s
                          end + user_second_business_service_days.collect do |service_day|
                                  service_day.total_time_in_care.to_s
                                end)
        expect(parsed_response.length).to eq(6)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with a business id and filter date' do
        params = { business: [user_second_business.id], filter_date: two_weeks_ago_week_current_date }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(user_second_business_past_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(user_second_business_past_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(user_second_business_past_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(
            user_second_business_past_service_days.collect { |service_day| service_day.total_time_in_care.to_s }
          )
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with multiple business ids and filter date' do
        params = { business: [business.id, user_second_business.id], filter_date: two_weeks_ago_week_current_date }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(user_second_business_past_service_days.collect(&:child_id) +
          past_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(user_second_business_past_service_days.collect(&:date) + past_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(user_second_business_past_service_days.collect(&:tags) + past_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(user_second_business_past_service_days.collect do |service_day|
                            service_day.total_time_in_care.to_s
                          end + past_service_days.collect do |service_day|
                                  service_day.total_time_in_care.to_s
                                end)
        expect(parsed_response.length).to eq(5)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays no service_days when sent with a business ID for the wrong user' do
        params = { business: [other_business.id] }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response).to eq([])
        expect(parsed_response.length).to eq(0)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent without a filter date' do
        get('/api/v1/service_days', params: {}, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(this_week_service_days.collect(&:child_id) +
          user_second_business_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(this_week_service_days.collect(&:date) + user_second_business_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(this_week_service_days.collect(&:tags) + user_second_business_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(this_week_service_days.collect do |service_day|
                            service_day.total_time_in_care.to_s
                          end + user_second_business_service_days.collect do |service_day|
                                  service_day.total_time_in_care.to_s
                                end)
        expect(parsed_response.length).to eq(6)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days in order by child last name' do
        get('/api/v1/service_days', params: {}, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.last['child']['last_name']).to eq('zzzz')
      end
    end

    context 'when logged in as an admin user' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'displays the service days with empty attendances if none exist' do
        Attendance.destroy_all
        get('/api/v1/service_days', params: {}, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('attendances').compact_blank).to be_empty
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with a filter date' do
        params = { filter_date: two_weeks_ago_week_current_date }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(past_service_days.collect(&:child_id) +
          user_second_business_past_service_days.collect(&:child_id) +
          another_user_past_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(past_service_days.collect(&:date) +
          user_second_business_past_service_days.collect(&:date) +
          another_user_past_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(past_service_days.collect(&:tags) +
          user_second_business_past_service_days.collect(&:tags) +
          another_user_past_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(past_service_days.collect do |service_day|
                            service_day.total_time_in_care.to_s
                          end + user_second_business_past_service_days.collect do |service_day|
                                  service_day.total_time_in_care.to_s
                                end + another_user_past_service_days.collect do |service_day|
                                        service_day.total_time_in_care.to_s
                                      end)
        expect(parsed_response.length).to eq(8)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with a business id' do
        params = { business: [other_business.id] }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(
            another_user_service_days.collect(&:child_id)
          )
        expect(parsed_response.pluck('date'))
          .to match_array(
            another_user_service_days.collect(&:date)
          )
        expect(parsed_response.pluck('tags'))
          .to match_array(
            another_user_service_days.collect(&:tags)
          )
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(
            another_user_service_days.collect { |service_day| service_day.total_time_in_care.to_s }
          )
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with multiple business ids' do
        params = { business: [business.id, other_business.id] }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(this_week_service_days.collect(&:child_id) + another_user_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(this_week_service_days.collect(&:date) + another_user_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(this_week_service_days.collect(&:tags) + another_user_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(this_week_service_days.collect do |service_day|
                            service_day.total_time_in_care.to_s
                          end + another_user_service_days.collect do |service_day|
                                  service_day.total_time_in_care.to_s
                                end)
        expect(parsed_response.length).to eq(6)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with a business id and filter date' do
        params = { business: [user_second_business.id], filter_date: two_weeks_ago_week_current_date }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(user_second_business_past_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(user_second_business_past_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(user_second_business_past_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(
            user_second_business_past_service_days.collect { |service_day| service_day.total_time_in_care.to_s }
          )
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent with multiple business ids and filter date' do
        params = { business: [other_business.id, user_second_business.id],
                   filter_date: two_weeks_ago_week_current_date }
        get('/api/v1/service_days', params:, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(user_second_business_past_service_days.collect(&:child_id) +
          another_user_past_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(user_second_business_past_service_days.collect(&:date) +
          another_user_past_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(user_second_business_past_service_days.collect(&:tags) +
          another_user_past_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(user_second_business_past_service_days.collect do |service_day|
                            service_day.total_time_in_care.to_s
                          end + another_user_past_service_days.collect do |service_day|
                                  service_day.total_time_in_care.to_s
                                end)
        expect(parsed_response.length).to eq(6)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days when sent without a filter date' do
        get('/api/v1/service_days', params: {}, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.pluck('child_id'))
          .to match_array(this_week_service_days.collect(&:child_id) +
          user_second_business_service_days.collect(&:child_id) +
          another_user_service_days.collect(&:child_id))
        expect(parsed_response.pluck('date'))
          .to match_array(this_week_service_days.collect(&:date) + user_second_business_service_days.collect(&:date) +
          another_user_service_days.collect(&:date))
        expect(parsed_response.pluck('tags'))
          .to match_array(this_week_service_days.collect(&:tags) + user_second_business_service_days.collect(&:tags) +
          another_user_service_days.collect(&:tags))
        expect(parsed_response.pluck('total_time_in_care'))
          .to match_array(this_week_service_days.collect { |service_day|
                            service_day.total_time_in_care.to_s
                          } + user_second_business_service_days.collect do |service_day|
                                service_day.total_time_in_care.to_s
                              end + another_user_service_days.collect do |service_day|
                                      service_day.total_time_in_care.to_s
                                    end)
        expect(parsed_response.length).to eq(9)
        expect(response).to match_response_schema('service_days')
      end

      it 'displays the service_days in order by child last name' do
        get('/api/v1/service_days', params: {}, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.last['child']['last_name']).to eq('zzzz')
      end
    end
  end

  describe 'POST /api/v1/service_days' do
    include_context 'with correct api version header'

    before { child.reload }

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
          date: (Time.current.in_time_zone(child.timezone).to_date + 1.day).to_s,
          child_id: child.id
        }
      }
    end

    let(:params_with_absence) do
      {
        service_day: {
          date: Helpers.prior_weekday(Time.current.in_time_zone(child.timezone).to_date, 1),
          child_id: child.id,
          absence_type: 'absence'
        }
      }
    end

    let(:params_with_bad_absence_reason) do
      {
        service_day: {
          date: Helpers.prior_weekday(Time.current.in_time_zone(child.timezone).to_date, 2),
          child_id: child.id,
          absence_type: 'not-an-absence'
        }
      }
    end

    context 'when logged in as a non-admin user' do
      before do
        sign_in logged_in_user
        child.reload
      end

      it 'creates a service_day for the child' do
        child.reload
        post('/api/v1/service_days', params: params_with_child_id, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response['child_id']).to eq(child.id)
        expect(child.reload.service_days.pluck(:date))
          .to include(Time.current.to_date.at_beginning_of_day + 1.day)
        expect(response).to match_response_schema('service_day')
        expect(response).to have_http_status(:created)
      end

      it 'does not create a service_day without a child id' do
        post('/api/v1/service_days', params: params_without_child_id, headers:)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a service_day with a bad absence type' do
        child.reload
        post('/api/v1/service_days', params: params_with_bad_absence_reason, headers:)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'creates an absence for the child' do
        child.reload
        post('/api/v1/service_days', params: params_with_absence, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response['child_id']).to eq(child.id)
        expect(parsed_response['absence_type']).to eq('absence_on_scheduled_day')
        expect(child.reload.service_days.map { |service_day| service_day.date.at_beginning_of_day })
          .to include(params_with_absence[:service_day][:date].at_beginning_of_day)
        expect(response).to match_response_schema('service_day')
        expect(response).to have_http_status(:created)
      end
    end

    context 'when logged in as an admin user' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'creates a service_day for the child' do
        child.reload
        post('/api/v1/service_days', params: params_with_child_id, headers:)
        parsed_response = response.parsed_body
        expect(parsed_response['child_id']).to eq(child.id)
        expect(child.reload.service_days.pluck(:date))
          .to include(Time.current.to_date.at_beginning_of_day + 1.day)
        expect(response).to match_response_schema('service_day')
        expect(response).to have_http_status(:created)
      end

      it 'does not create a service_day without a child id' do
        post('/api/v1/service_days', params: params_without_child_id, headers:)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a service_day with a bad absence type' do
        post('/api/v1/service_days', params: params_with_bad_absence_reason, headers:)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
