# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'users API', type: :request do
  # Do not send any emails (no confirmation emails, no password was changed emails)
  before(:each) do
    allow_any_instance_of(User).to receive(:send_confirmation_notification?).and_return(false)
    allow_any_instance_of(User).to receive(:send_password_change_notification?).and_return(false)
  end

  let!(:user_params) do
    {
      email: 'fake_email@fake_email.com',
      full_name: 'Oliver Twist',
      greeting_name: 'Oliver',
      language: 'English',
      organization: 'Society for the Promotion of Elfish Welfare',
      password: 'password1234!',
      password_confirmation: 'password1234!',
      phone_number: '912-444-5555',
      phone_type: 'cell',
      service_agreement_accepted: 'true',
      timezone: 'Central Time (US & Canada)'
    }
  end

  describe 'list users' do
    path '/api/v1/users' do
      get 'retrieves all users' do
        tags 'users'

        produces 'application/json'

        context 'on the right api version' do
          include_context 'correct api version header'
          context 'admin users' do
            include_context 'admin user'
            response '200', 'users found' do
              run_test! do
                expect(response).to match_response_schema('users')
              end
            end
          end

          context 'non-admin users' do
            include_context 'authenticated user'
            response '403', 'forbidden' do
              run_test!
            end
          end

          it_behaves_like '401 error if not authenticated with parameters', 'user'
        end

        it_behaves_like 'server error responses for wrong api version with parameters', 'user'
      end
    end
  end

  describe 'user profile' do
    path '/api/v1/profile' do
      let(:record_params) { user_params }

      get 'retrieves the user profile' do
        tags 'users'

        produces 'application/json'

        context 'on the right api version' do
          include_context 'correct api version header'
          context 'when authenticated' do
            include_context 'authenticated user'
            response '200', 'profile found' do
              run_test! do
                expect(response).to match_response_schema('user')
              end
            end
          end

          it_behaves_like '401 error if not authenticated with parameters', 'user'
        end

        it_behaves_like 'server error responses for wrong api version with parameters', 'user'
      end
    end
  end

  describe '#case_list_for_dashboard' do
    let!(:owner) { create(:confirmed_user) }
    let!(:created_business) { create(:business, user: owner) }
    let!(:non_owner_business) { create(:business, zipcode: created_business.zipcode, county: created_business.county) }
    let(:count) { 2 }
    let(:owner_attributes) { { business: created_business } }
    let(:non_owner_attributes) { { business: non_owner_business } }
    before do
      sign_in owner
    end
    path '/api/v1/case_list_for_dashboard' do
      get 'lists all cases with associated data for a user' do
        tags 'children', 'dashboard'

        # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
        produces 'application/json'

        # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
        # security [{ token: [] }]

        include_context 'correct api version header'
        let!(:expired_approval) { create(:expired_approval, case_number: '1234567A', create_children: false) }
        let!(:expired_approvals) { create_list(:expired_approval, count, create_children: false) }
        let!(:current_approval) { create(:approval, case_number: '1234567B', create_children: false) }
        let!(:current_approvals) { create_list(:approval, count, create_children: false) }
        let!(:owner_records) { create_list(:child_in_illinois, count, :with_three_attendances, owner_attributes.merge(approvals: [expired_approval, current_approval])) }
        let!(:owner_inactive_records) do
          create_list(:child_in_illinois, count, :with_two_attendances, owner_attributes.merge(active: false, approvals: [expired_approvals.sample, current_approvals.sample]))
        end
        let!(:non_owner_records) do
          create_list(:child_in_illinois, count, :with_two_attendances, non_owner_attributes.merge(approvals: [expired_approvals.sample, current_approvals.sample]))
        end
        let!(:non_owner_inactive_records) do
          create_list(:child_in_illinois, count, :with_two_attendances,
                      non_owner_attributes.merge(active: false, approvals: [expired_approvals.sample, current_approvals.sample]))
        end
        let(:subsidy_rule) { create(:subsidy_rule_for_illinois, :fifty_percent) }
        let(:first_child) { owner_records.first }
        let(:last_child) { owner_records.last }
        before do
          ([expired_approval, current_approval] + expired_approvals + current_approvals).each do |approval|
            approval.children.each { |child| child.active_child_approval(Time.current).update!(subsidy_rule: subsidy_rule) }
          end
        end

        context 'admin user' do
          let!(:admin) { create(:admin) }
          before { sign_in admin }

          before { freeze_time }
          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)
              expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count * 2)
              expect(json.collect { |user| user.dig_and_collect('businesses', 'cases', 'case_number') }.flatten).to include(/1234567B/)
              expect(json.collect { |user| user['as_of'] }.flatten).to include(Time.current.strftime('%m/%d/%Y'))
              expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
            end
          end

          response '200', 'when requesting a month with attendances and approvals' do
            before do
              travel_to Time.zone.today - 1.month
              owner.businesses.first.children.active.each do |child|
                current_child_approval = child.active_child_approval(Time.zone.today)
                create(:illinois_part_day_attendance,
                       child_approval: current_child_approval)
                create(:illinois_full_day_attendance,
                       child_approval: current_child_approval)
                create(:illinois_full_plus_part_day_attendance,
                       child_approval: current_child_approval)
              end
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count * 2)
              expect(json.collect { |user| user.dig_and_collect('businesses', 'cases', 'case_number') }.flatten).to include(/1234567B/)
              expect(json.collect { |user| user['as_of'] }.flatten).to include(owner.latest_attendance_in_month(Time.current).strftime('%m/%d/%Y'))
              expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
            end
          end
        end

        context 'resource owner' do
          before { sign_in owner }

          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)
              expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count)
              expect(response).to match_response_schema('illinois_case_list_for_dashboard')
            end
          end
        end

        context 'with attendance risk calculations' do
          before { sign_in owner }

          response '200', 'with a sure_bet family' do
            before do
              travel_to Date.parse('December 23, 2020')
              first_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 1, full_days_approved_per_week: 0)
              last_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 0, full_days_approved_per_week: 1)
              owner.businesses.first.children.each do |child|
                current_child_approval = child.active_child_approval(Time.current)
                create_list(:illinois_part_day_attendance, 10,
                            child_approval: current_child_approval,
                            check_in: Time.zone.today - rand(1..5).days)
                create_list(:illinois_full_day_attendance, 10,
                            child_approval: current_child_approval,
                            check_in: Time.zone.today - rand(1..5).days)
              end
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json
                .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
                .flatten)
                .to eq(%w[sure_bet sure_bet])
            end
          end

          response '200', 'with a family with a sure_bet child and an on_track child' do
            before do
              travel_to Date.parse('December 23, 2020')
              first_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 1, full_days_approved_per_week: 2)
              last_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 0, full_days_approved_per_week: 1)
              owner.businesses.first.children.each do |child|
                current_child_approval = child.active_child_approval(Time.current)
                create_list(:illinois_full_day_attendance, 10,
                            child_approval: current_child_approval,
                            check_in: Time.zone.today - rand(1..5).days)
              end
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json
                .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
                .flatten)
                .to eq(%w[on_track sure_bet])
            end
          end

          response '200', 'with an on_track family' do
            before do
              travel_to Date.parse('December 23, 2020')
              first_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 3, full_days_approved_per_week: 2)
              last_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 2, full_days_approved_per_week: 3)
              owner.businesses.first.children.each do |child|
                current_child_approval = child.active_child_approval(Time.current)
                create_list(:illinois_part_day_attendance, 5,
                            child_approval: current_child_approval,
                            check_in: Time.zone.today - rand(1..5).days)
                create_list(:illinois_full_day_attendance, 5,
                            child_approval: current_child_approval,
                            check_in: Time.zone.today - rand(1..5).days)
              end
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json
                .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
                .flatten)
                .to eq(%w[on_track on_track])
            end
          end

          response '200', 'with an at_risk family' do
            before do
              travel_to Date.parse('December 23, 2020')
              first_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 3, full_days_approved_per_week: 2)
              last_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 2, full_days_approved_per_week: 3)
              owner.businesses.first.children.each do |child|
                current_child_approval = child.active_child_approval(Time.current)
                create_list(:illinois_part_day_attendance, 4,
                            child_approval: current_child_approval,
                            check_in: Time.zone.today - rand(1..5).days)
                create_list(:illinois_full_day_attendance, 3,
                            child_approval: current_child_approval,
                            check_in: Time.zone.today - rand(1..5).days)
              end
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json
                .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
                .flatten)
                .to eq(%w[at_risk at_risk])
            end
          end

          response '200', 'with a not_met family' do
            before do
              travel_to Date.parse('December 23, 2020')
              first_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 3, full_days_approved_per_week: 2)
              last_child
                .active_child_approval(Time.current)
                .illinois_approval_amounts
                .for_month
                .first
                .update!(part_days_approved_per_week: 2, full_days_approved_per_week: 3)
              owner.businesses.first.children.each do |child|
                current_child_approval = child.active_child_approval(Time.current)
                create(:illinois_part_day_attendance,
                       child_approval: current_child_approval,
                       check_in: Time.zone.today - rand(1..5).days)
                create(:illinois_full_day_attendance,
                       child_approval: current_child_approval,
                       check_in: Time.zone.today - rand(1..5).days)
              end
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json
                .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
                .flatten)
                .to eq(%w[not_met not_met])
            end
          end

          response '200', 'with a not_enough_info date' do
            before do
              travel_to Date.parse('December 11, 2020')
              create(:approval, num_children: 2)
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json
                  .collect { |user| user.dig_and_collect('businesses', 'cases', 'attendance_risk') }
                  .flatten)
                .to eq(%w[not_enough_info not_enough_info])
            end
          end
        end

        context 'nebraska user' do
          let!(:nebraska_owner) { create(:confirmed_user) }
          let!(:business) { create(:business, :nebraska, user: nebraska_owner) }
          let!(:owner_records) { create_list(:child, count, { business: business, approvals: [expired_approval, current_approval] }) }
          let!(:owner_inactive_records) { create_list(:child, count, { business: business, active: false, approvals: [expired_approvals.sample, current_approvals.sample] }) }
          before do
            sign_in nebraska_owner
          end
          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)
              expect(json.collect { |user| user.dig_and_collect('businesses', 'cases') }.flatten.size).to eq(count)
              expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
            end
          end
        end

        context 'non-owner' do
          include_context 'authenticated user'
          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)

              expect(json
                .collect { |user| user.dig_and_collect('businesses') }
                .flatten.size)
                .to eq(0)
            end
          end
        end
      end
    end
  end
end
