# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  # Do not send any emails (no confirmation emails, no password was changed emails)
  before(:each) do
    allow_any_instance_of(User).to receive(:send_confirmation_notification?).and_return(false)
    allow_any_instance_of(User).to receive(:send_password_change_notification?).and_return(false)
  end

  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:other_user) { create(:confirmed_user) }
  let!(:admin_user) { create(:confirmed_user, admin: true) }

  describe 'GET /api/v1/users' do
    include_context 'correct api version header'

    context 'for non-admin user' do
      before do
        sign_in logged_in_user
      end

      it 'returns only the user' do
        get '/api/v1/users', headers: headers
        expect(response.status).to eq(403)
      end
    end

    context 'for admin user' do
      before do
        sign_in admin_user
      end

      it 'returns all users' do
        get '/api/v1/users', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['greeting_name'] }).to include(logged_in_user.greeting_name)
        expect(parsed_response.collect { |x| x['greeting_name'] }).to include(other_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('users')
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    include_context 'correct api version header'

    context 'for non-admin user' do
      before do
        sign_in logged_in_user
      end

      it 'returns the user using their ID' do
        get "/api/v1/users/#{logged_in_user.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(logged_in_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('user')
      end

      it 'returns the user using /profile' do
        get '/api/v1/profile', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(logged_in_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('user')
      end

      it 'does not return another user' do
        get "/api/v1/users/#{other_user.id}", headers: headers
        expect(response.status).to eq(404)
      end
    end

    context 'for admin user' do
      before do
        sign_in admin_user
      end

      it 'returns the user' do
        get "/api/v1/users/#{logged_in_user.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(logged_in_user.greeting_name)
        expect(response).to match_response_schema('user')
      end

      it 'returns the admin user using /profile' do
        get '/api/v1/profile', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(admin_user.greeting_name)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('user')
      end

      it 'returns the other user' do
        get "/api/v1/users/#{other_user.id}", headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['greeting_name']).to eq(other_user.greeting_name)
        expect(response).to match_response_schema('user')
      end

      # TODO: requires user policy changes
      # it 'returns the other user' do
      #   get "/api/v1/users/#{other_user.id}", headers: headers
      #   parsed_response = JSON.parse(response.body)
      #   expect(parsed_response['greeting_name']).to eq(other_user.greeting_name)
      #   expect(response).to match_response_schema('user')
      # end
    end
  end

  describe 'GET /api/v1/case_list_for_dashboard' do
    include_context 'correct api version header'
    let!(:nebraska_user) { create(:confirmed_user) }
    let!(:nebraska_business) { create(:business, :nebraska, user: nebraska_user) }
    let!(:nebraska_user_children) do
      create_list(:child, 2, {
                    business: nebraska_business,
                    approvals: [
                      create(:expired_approval, create_children: false),
                      create(:approval, create_children: false)
                    ]
                  })
    end
    let!(:illinois_user) { create(:confirmed_user) }
    let!(:illinois_business) { create(:business, user: illinois_user) }
    let!(:illinois_user_children) do
      create_list(:child, 2, {
                    business: illinois_business,
                    approvals: [
                      create(:expired_approval, create_children: false),
                      create(:approval, create_children: false)
                    ]
                  })
    end

    context 'for non-admin user in illinois' do
      before do
        sign_in illinois_user
      end

      it 'returns the correct data schema' do
        get '/api/v1/case_list_for_dashboard', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(2)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('illinois_case_list_for_dashboard')
      end

      it 'returns the correct cases when a filter_date is sent' do
        get '/api/v1/case_list_for_dashboard', params: { filter_date: '2017-12-12' }, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('illinois_case_list_for_dashboard')
      end
    end

    context 'for non-admin user in nebraska' do
      before do
        sign_in nebraska_user
      end

      it 'returns the correct data schema' do
        get '/api/v1/case_list_for_dashboard', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(2)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end

      it 'returns the correct cases when a filter_date is sent' do
        get '/api/v1/case_list_for_dashboard', params: { filter_date: '2017-12-12' }, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(0)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end
    end

    context 'for admin user' do
      before do
        sign_in admin_user
      end

      it 'returns the correct data schema' do
        get '/api/v1/case_list_for_dashboard', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(4)
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
      end
    end
  end
end

# european standards

#     let(:illinois_rate) { create(:illinois_rate, :fifty_percent) }
#     let(:first_child) { owner_records.first }
#     let(:last_child) { owner_records.last }
#     before do
#       ([expired_approval, current_approval] + expired_approvals + current_approvals).each do |approval|
#         approval.children.each { |child| child.active_child_approval(Time.current).update!(rate: illinois_rate) }
#       end
#     end

#     context 'admin user' do
#       let!(:admin) { create(:admin) }
#       before { sign_in admin }

#       before { freeze_time }
#       response '200', 'active cases found' do
#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count * 2)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases', 'case_number') }.flatten).to include(/1234567B/)
#           expect(json.collect { |user| user['as_of'] }.flatten).to include(Time.current.strftime('%m/%d/%Y'))
#           expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
#         end
#       end

#       response '200', 'when requesting a month with attendances and approvals' do
#         before do
#           travel_to Time.zone.today - 1.month
#           owner.businesses.first.children.active.each do |child|
#             current_child_approval = child.active_child_approval(Time.zone.today)
#             create(:illinois_part_day_attendance,
#                    child_approval: current_child_approval)
#             create(:illinois_full_day_attendance,
#                    child_approval: current_child_approval)
#             create(:illinois_full_plus_part_day_attendance,
#                    child_approval: current_child_approval)
#           end
#         end
#         after { travel_back }

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count * 2)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases', 'case_number') }.flatten).to include(/1234567B/)
#           expect(json.collect { |user| user['as_of'] }.flatten).to include(owner.latest_attendance_in_month(Time.current).strftime('%m/%d/%Y'))
#           expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
#         end
#       end
#     end

#     context 'resource owner' do
#       before { sign_in owner }

#       response '200', 'active cases found' do
#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count)
#           expect(response).to match_response_schema('illinois_case_list_for_dashboard')
#         end
#       end
#     end

#     context 'include inactive child' do
#       before { sign_in owner }

#       response '200', 'active cases found' do
#         before do
#           first_child
#             .update!(active: false)
#         end

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases', 'active') }.flatten).to include(false, true)
#         end
#       end
#     end

#     context 'exclude deleted child' do
#       before { sign_in owner }

#       response '200', 'active cases found' do
#         before do
#           last_child
#             .update!(deleted: true)
#         end

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases', 'id') }.flatten).to include(first_child.id)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases', 'id') }.flatten).not_to include(last_child.id)
#         end
#       end
#     end

#     context 'with attendance risk calculations' do
#       before { sign_in owner }

#       response '200', 'with a sure_bet family' do
#         before do
#           travel_to Date.parse('December 23, 2020')
#           first_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 1, full_days_approved_per_week: 0)
#           last_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 0, full_days_approved_per_week: 1)
#           owner.businesses.first.children.each do |child|
#             current_child_approval = child.active_child_approval(Time.current)
#             create_list(:illinois_part_day_attendance, 10,
#                         child_approval: current_child_approval,
#                         check_in: Time.zone.today - rand(1..5).days)
#             create_list(:illinois_full_day_attendance, 10,
#                         child_approval: current_child_approval,
#                         check_in: Time.zone.today - rand(1..5).days)
#           end
#         end
#         after { travel_back }

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json
#             .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
#             .flatten)
#             .to eq(%w[sure_bet sure_bet])
#         end
#       end

#       response '200', 'with a family with a sure_bet child and an on_track child' do
#         before do
#           travel_to Date.parse('December 23, 2020')
#           first_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 1, full_days_approved_per_week: 2)
#           last_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 0, full_days_approved_per_week: 1)
#           owner.businesses.first.children.each do |child|
#             current_child_approval = child.active_child_approval(Time.current)
#             create_list(:illinois_full_day_attendance, 10,
#                         child_approval: current_child_approval,
#                         check_in: Time.zone.today - rand(1..5).days)
#           end
#         end
#         after { travel_back }

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json
#             .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
#             .flatten)
#             .to eq(%w[on_track sure_bet])
#         end
#       end

#       response '200', 'with an on_track family' do
#         before do
#           travel_to Date.parse('December 23, 2020')
#           first_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 3, full_days_approved_per_week: 2)
#           last_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 2, full_days_approved_per_week: 3)
#           owner.businesses.first.children.each do |child|
#             current_child_approval = child.active_child_approval(Time.current)
#             create_list(:illinois_part_day_attendance, 5,
#                         child_approval: current_child_approval,
#                         check_in: Time.zone.today - rand(1..5).days)
#             create_list(:illinois_full_day_attendance, 5,
#                         child_approval: current_child_approval,
#                         check_in: Time.zone.today - rand(1..5).days)
#           end
#         end
#         after { travel_back }

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json
#             .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
#             .flatten)
#             .to eq(%w[on_track on_track])
#         end
#       end

#       response '200', 'with an at_risk family' do
#         before do
#           travel_to Date.parse('December 23, 2020')
#           first_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 3, full_days_approved_per_week: 2)
#           last_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 2, full_days_approved_per_week: 3)
#           owner.businesses.first.children.each do |child|
#             current_child_approval = child.active_child_approval(Time.current)
#             create_list(:illinois_part_day_attendance, 4,
#                         child_approval: current_child_approval,
#                         check_in: Time.zone.today - rand(1..5).days)
#             create_list(:illinois_full_day_attendance, 3,
#                         child_approval: current_child_approval,
#                         check_in: Time.zone.today - rand(1..5).days)
#           end
#         end
#         after { travel_back }

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json
#             .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
#             .flatten)
#             .to eq(%w[at_risk at_risk])
#         end
#       end

#       response '200', 'with a not_met family' do
#         before do
#           travel_to Date.parse('December 23, 2020')
#           first_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 3, full_days_approved_per_week: 2)
#           last_child
#             .active_child_approval(Time.current)
#             .illinois_approval_amounts
#             .for_month
#             .first
#             .update!(part_days_approved_per_week: 2, full_days_approved_per_week: 3)
#           owner.businesses.first.children.each do |child|
#             current_child_approval = child.active_child_approval(Time.current)
#             create(:illinois_part_day_attendance,
#                    child_approval: current_child_approval,
#                    check_in: Time.zone.today - rand(1..5).days)
#             create(:illinois_full_day_attendance,
#                    child_approval: current_child_approval,
#                    check_in: Time.zone.today - rand(1..5).days)
#           end
#         end
#         after { travel_back }

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json
#             .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
#             .flatten)
#             .to eq(%w[not_met not_met])
#         end
#       end

#       response '200', 'with a not_enough_info date' do
#         before do
#           travel_to Date.parse('December 11, 2020')
#           create(:approval, num_children: 2)
#         end
#         after { travel_back }

#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json
#               .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
#               .flatten)
#             .to eq(%w[not_enough_info not_enough_info])
#         end
#       end
#     end

#     context 'nebraska user' do
#       let!(:nebraska_owner) { create(:confirmed_user) }
#       let!(:business) { create(:business, :nebraska, user: nebraska_owner) }
#       let!(:owner_records) { create_list(:child, count, { business: business, approvals: [expired_approval, current_approval] }) }
#       let!(:owner_deleted_records) { create_list(:child, count, { business: business, deleted: true, approvals: [expired_approvals.sample, current_approvals.sample] }) }
#       before do
#         sign_in nebraska_owner
#       end
#       response '200', 'active cases found' do
#         run_test! do
#           json = JSON.parse(response.body)
#           expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count)
#           expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
#         end
#       end
#     end

#     context 'non-owner' do
#       include_context 'authenticated user'
#       response '200', 'active cases found' do
#         run_test! do
#           json = JSON.parse(response.body)

#           expect(json
#             .collect { |user| user.dig_and_collect('businesses') }
#             .flatten.size)
#             .to eq(0)
#         end
#       end
#     end
#   end
# end
