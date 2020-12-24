# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: user) }
  let!(:non_owner_business) { create(:business, zipcode: created_business.zipcode, county: created_business.county) }
  let!(:record_params) do
    {
      "child": {
        "full_name": 'Parvati Patil',
        "date_of_birth": '1981-04-09',
        "business_id": created_business.id,
        "approvals_attributes": [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
      }
    }
  end
  let!(:all_months_amounts) do
    {
      "child": {
        "full_name": 'Parvati Patil',
        "date_of_birth": '1981-04-09',
        "business_id": created_business.id,
        "approvals_attributes": [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
      },
      "first_month_name": 'March',
      "first_month_year": '2020',
      "month1": {
        "part_days_approved_per_week": 4,
        "full_days_approved_per_week": 1
      },
      "month2": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month3": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month4": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month5": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month6": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month7": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month8": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month9": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month10": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month11": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month12": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      }
    }
  end
  let!(:some_months_amounts) do
    {
      "child": {
        "full_name": 'Parvati Patil',
        "date_of_birth": '1981-04-09',
        "business_id": created_business.id,
        "approvals_attributes": [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
      },
      "first_month_name": 'March',
      "first_month_year": '2020',
      "month1": {
        "part_days_approved_per_week": 4,
        "full_days_approved_per_week": 1
      },
      "month2": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month3": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month4": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month5": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      },
      "month6": {
        "part_days_approved_per_week": 3,
        "full_days_approved_per_week": 2
      }
    }
  end
  let!(:one_month_amounts) do
    {
      "child": {
        "full_name": 'Parvati Patil',
        "date_of_birth": '1981-04-09',
        "business_id": created_business.id,
        "approvals_attributes": [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
      },
      "first_month_name": 'March',
      "first_month_year": '2020',
      "month1": {
        "part_days_approved_per_week": 4,
        "full_days_approved_per_week": 1
      }
    }
  end
  let!(:amounts_without_first_month) do
    {
      "child": {
        "full_name": 'Parvati Patil',
        "date_of_birth": '1981-04-09',
        "business_id": created_business.id,
        "approvals_attributes": [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
      },
      "month1": {
        "part_days_approved_per_week": 4,
        "full_days_approved_per_week": 1
      }
    }
  end
  let(:count) { 2 }
  let(:owner) { user }
  let(:owner_attributes) { { business: created_business } }
  let(:non_owner_attributes) { { business: non_owner_business } }
  let(:record) { Child.create! record_params[:child] }

  it_behaves_like 'it lists all records for a user', Child

  context 'on the correct api version' do
    include_context 'correct api version header'

    describe 'POST children#create' do
      context 'with valid params' do
        context 'as an admin user' do
          include_context 'admin user'
          it 'creates a child with the expected attributes' do
            post '/api/v1/children', params: record_params, headers: headers
            expect(response.status).to eq(201)
            expect(response).to match_response_schema('child')
          end
        end
        context 'as a non-admin user' do
          include_context 'authenticated user'
          it 'creates a child with the expected attributes' do
            post '/api/v1/children', params: record_params, headers: headers
            expect(response.status).to eq(201)
            expect(response).to match_response_schema('child')
          end
        end
        context 'without authentication' do
          it 'returns an unauthenticated error' do
            post '/api/v1/children', params: record_params, headers: headers
            expect(response.status).to eq(401)
          end
        end
      end

      context 'with all months included in the params' do
        include_context 'admin user'
        it 'creates a child with the expected attributes and creates the correct number of approval amounts' do
          post '/api/v1/children', params: all_months_amounts, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(12)
          expect(child.child_approvals.first.illinois_approval_amounts.first.month).to eq(
            Date.parse(
              all_months_amounts[:first_month_name],
              all_months_amounts[:first_month_year]
            )
          )
          expect(response).to match_response_schema('child')
        end
      end

      context 'with a single month included in the params' do
        include_context 'admin user'
        it 'creates a child with the expected attributes and creates 12 approval amounts' do
          post '/api/v1/children', params: one_month_amounts, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(12)
          expect(child.child_approvals.first.illinois_approval_amounts.first.month).to eq(
            Date.parse(
              one_month_amounts[:first_month_name],
              one_month_amounts[:first_month_year]
            )
          )
          expect(response).to match_response_schema('child')
        end
      end

      context 'with some months included in the params' do
        include_context 'admin user'
        it 'creates a child with the expected attributes and creates the correct number of approval amounts' do
          post '/api/v1/children', params: some_months_amounts, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(6)
          expect(child.child_approvals.first.illinois_approval_amounts.first.month).to eq(
            Date.parse(
              some_months_amounts[:first_month_name],
              some_months_amounts[:first_month_year]
            )
          )
          expect(response).to match_response_schema('child')
        end
      end

      context 'without the first_month parameters' do
        include_context 'admin user'
        it 'creates a child with the expected attributes and does not create approval amounts' do
          post '/api/v1/children', params: amounts_without_first_month, headers: headers
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(0)
          expect(response).to match_response_schema('child')
        end
      end

      context 'with invalid params' do
        let(:record_params) { { "child": { 'this_param': 'bad_params' } } }
        context 'as an admin user' do
          include_context 'admin user'
          it 'returns an invalid request response' do
            post '/api/v1/children', params: record_params, headers: headers
            expect(response.status).to eq(422)
          end
        end
        context 'as a non-admin user' do
          include_context 'authenticated user'
          it 'returns an invalid request response' do
            post '/api/v1/children', params: record_params, headers: headers
            expect(response.status).to eq(422)
          end
        end
        context 'without authentication' do
          it 'returns an unauthenticated error' do
            post '/api/v1/children', params: record_params, headers: headers
            expect(response.status).to eq(401)
          end
        end
      end
    end
  end

  context 'on an incorrect api version' do
    include_context 'incorrect api version header'

    describe 'POST children#create' do
      context 'as an admin user' do
        include_context 'admin user'
        it 'returns a server error' do
          post '/api/v1/children', params: record_params, headers: headers
          expect(response.status).to eq(500)
        end
      end
      context 'as a non-admin user' do
        include_context 'authenticated user'
        it 'returns a server error' do
          post '/api/v1/children', params: record_params, headers: headers
          expect(response.status).to eq(500)
        end
      end
      context 'without authentication' do
        it 'returns an unauthenticated error' do
          post '/api/v1/children', params: record_params, headers: headers
          expect(response.status).to eq(500)
        end
      end
    end
  end

  # the params for this item are now multi-leveled and complex, so this fails
  # it_behaves_like 'it creates a record', Child

  it_behaves_like 'admins and resource owners can retrieve a record', Child

  it_behaves_like 'admins and resource owners can update a record', Child, 'full_name', 'Padma Patil', nil

  it_behaves_like 'admins and resource owners can delete a record', Child

  describe '#case_list_for_dashboard' do
    path '/api/v1/case_list_for_dashboard' do
      get 'lists all cases with associated data for a user' do
        tags 'children', 'dashboard'

        # rswag requires a call to :produces if you are going to set Accept header info. See Rswag::Specs::RequestFactory#add_headers
        produces 'application/json'

        # parameter name: 'Authorization', in: :header, type: :string, default: 'Bearer <token>'
        # security [{ token: [] }]

        include_context 'correct api version header'
        let!(:expired_approval) { create(:approval, effective_on: Date.parse('January 11, 2018'), case_number: '1234567A', create_children: false) }
        let!(:expired_approvals) { create_list(:approval, count, effective_on: Date.parse('January 11, 2018'), create_children: false) }
        let!(:current_approval) { create(:approval, effective_on: Date.parse('January 11, 2020'), case_number: '1234567B', create_children: false) }
        let!(:current_approvals) { create_list(:approval, count, effective_on: Date.parse('January 11, 2020'), create_children: false) }
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
            approval.children.each { |child| child.current_child_approval.update!(subsidy_rule: subsidy_rule) }
          end
        end

        context 'admin user' do
          include_context 'admin user'

          before { freeze_time }
          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)
              expect(json.size).to eq(count * 2)
              expect(json.first['approvals'].size).to eq(1)
              expect(json.first['approvals'].first['case_number']).to eq('1234567B')
              expect(json.first['attendance_rate']).to eq(0)
              expect(json.first['as_of']).to eq(DateTime.now.strftime('%m/%d/%Y'))
              expect(response).to match_response_schema('illinois_case_list_for_dashboard')
            end
          end
          response '200', 'when requesting a month with attendances and approvals' do
            before { travel_to Date.parse('March 28, 2020').in_time_zone(user.timezone) }
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.size).to eq(count * 2)
              expect(json.first['approvals'].size).to eq(1)
              expect(json.first['approvals'].first['case_number']).to eq('1234567B')
              expect(json.first['attendance_rate']).to eq(0.16)
              expect(json.first['as_of']).to eq('03/12/2020')
              expect(response).to match_response_schema('illinois_case_list_for_dashboard')
            end
          end
        end

        context 'resource owner' do
          before { sign_in owner }

          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)
              expect(json.size).to eq(count)
              expect(response).to match_response_schema('illinois_case_list_for_dashboard')
            end
          end
        end

        context 'with attendance risk calculations' do
          before do
            sign_in user
          end

          response '200', 'with a sure_bet family' do
            before do
              travel_to Date.parse('December 23, 2020').in_time_zone(user.timezone)
              create(:illinois_approval_amount, child_approval: first_child.current_child_approval, part_days_approved_per_week: 1, full_days_approved_per_week: 0,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))
              create(:illinois_approval_amount, child_approval: last_child.current_child_approval, part_days_approved_per_week: 0, full_days_approved_per_week: 1,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))

              create_list(:illinois_part_day_attendance, 5, child_approval: first_child.current_child_approval, check_in: Time.zone.today - rand(1..5).days)
              create_list(:illinois_full_day_attendance, 5, child_approval: last_child.current_child_approval)
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.first['attendance_risk']).to eq('sure_bet')
              expect(json[1]['attendance_risk']).to eq('sure_bet')
            end
          end

          response '200', 'with a family with a sure_bet child and an on_track child' do
            before do
              travel_to Date.parse('December 23, 2020').in_time_zone(user.timezone)
              create(:illinois_approval_amount, child_approval: first_child.current_child_approval, part_days_approved_per_week: 1, full_days_approved_per_week: 2,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))
              create(:illinois_approval_amount, child_approval: last_child.current_child_approval, part_days_approved_per_week: 0, full_days_approved_per_week: 1,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))

              create_list(:illinois_part_day_attendance, 5, child_approval: first_child.current_child_approval, check_in: Time.zone.today - rand(1..5).days)
              create_list(:illinois_full_day_attendance, 5, child_approval: last_child.current_child_approval)
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.first['attendance_risk']).to eq('on_track')
              expect(json[1]['attendance_risk']).to eq('sure_bet')
            end
          end

          response '200', 'with an on_track family' do
            before do
              travel_to Date.parse('December 23, 2020').in_time_zone(user.timezone)
              create(:illinois_approval_amount, child_approval: first_child.current_child_approval, part_days_approved_per_week: 3, full_days_approved_per_week: 2,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))
              create(:illinois_approval_amount, child_approval: last_child.current_child_approval, part_days_approved_per_week: 2, full_days_approved_per_week: 3,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))

              create_list(:illinois_part_day_attendance, 5, child_approval: first_child.current_child_approval, check_in: Time.zone.today - rand(1..5).days)
              create_list(:illinois_full_day_attendance, 5, child_approval: first_child.current_child_approval)
              create_list(:illinois_part_day_attendance, 5, child_approval: last_child.current_child_approval)
              create_list(:illinois_full_day_attendance, 5, child_approval: last_child.current_child_approval)
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.first['attendance_risk']).to eq('on_track')
              expect(json[1]['attendance_risk']).to eq('on_track')
            end
          end

          response '200', 'with an at_risk family' do
            before do
              travel_to Date.parse('December 23, 2020').in_time_zone(user.timezone)
              create(:illinois_approval_amount, child_approval: first_child.current_child_approval, part_days_approved_per_week: 3, full_days_approved_per_week: 2,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))
              create(:illinois_approval_amount, child_approval: last_child.current_child_approval, part_days_approved_per_week: 2, full_days_approved_per_week: 3,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))

              create_list(:illinois_part_day_attendance, 4, child_approval: first_child.current_child_approval, check_in: Time.zone.today - rand(1..4).days)
              create_list(:illinois_full_day_attendance, 3, child_approval: first_child.current_child_approval)
              create_list(:illinois_part_day_attendance, 4, child_approval: last_child.current_child_approval)
              create_list(:illinois_full_day_attendance, 3, child_approval: last_child.current_child_approval)
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.first['attendance_risk']).to eq('at_risk')
              expect(json[1]['attendance_risk']).to eq('at_risk')
            end
          end

          response '200', 'with a not_met family' do
            before do
              travel_to Date.parse('December 23, 2020').in_time_zone(user.timezone)
              create(:illinois_approval_amount, child_approval: first_child.current_child_approval, part_days_approved_per_week: 3, full_days_approved_per_week: 2,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))
              create(:illinois_approval_amount, child_approval: last_child.current_child_approval, part_days_approved_per_week: 2, full_days_approved_per_week: 3,
                                                month: Time.zone.today.at_beginning_of_month.in_time_zone(user.timezone))

              create_list(:illinois_part_day_attendance, 1, child_approval: first_child.current_child_approval, check_in: Time.zone.today - 4.hours)
              create_list(:illinois_full_day_attendance, 1, child_approval: first_child.current_child_approval)
              create_list(:illinois_part_day_attendance, 1, child_approval: last_child.current_child_approval)
              create_list(:illinois_full_day_attendance, 1, child_approval: last_child.current_child_approval)
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.first['attendance_risk']).to eq('not_met')
              expect(json[1]['attendance_risk']).to eq('not_met')
            end
          end

          response '200', 'with a not_enough_info date' do
            before do
              travel_to Date.parse('December 11, 2020').in_time_zone(user.timezone)
              create(:approval, num_children: 2)
            end
            after { travel_back }

            run_test! do
              json = JSON.parse(response.body)
              expect(json.first['attendance_risk']).to eq('not_enough_info')
            end
          end
        end

        context 'nebraska user' do
          let!(:owner) { create(:confirmed_user) }
          let!(:business) { create(:business, :nebraska, user: owner) }
          let!(:owner_records) { create_list(:child, count, { business: business, approvals: [expired_approval, current_approval] }) }
          let!(:owner_inactive_records) { create_list(:child, count, { business: business, active: false, approvals: [expired_approvals.sample, current_approvals.sample] }) }
          before do
            sign_in owner
          end
          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)
              expect(json.size).to eq(count)
              expect(response).to match_response_schema('nebraska_case_list_for_dashboard')
            end
          end
        end

        context 'non-owner' do
          include_context 'authenticated user'
          response '200', 'active cases found' do
            run_test! do
              json = JSON.parse(response.body)
              expect(json.size).to eq(0)
            end
          end
        end
      end
    end
  end
end
