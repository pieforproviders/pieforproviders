# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'children API', type: :request do
  let!(:user) { create(:confirmed_user) }
  let!(:created_business) { create(:business, user: user) }
  let!(:non_owner_business) { create(:business, zipcode: created_business.zipcode, county: created_business.county) }
  let!(:record_params) do
    {
      "full_name": 'Parvati Patil',
      "date_of_birth": '1981-04-09',
      "business_id": created_business.id,
      "approvals_attributes": [attributes_for(:approval)]
    }
  end
  let(:count) { 2 }
  let(:owner) { user }
  let(:owner_attributes) { { business: created_business } }
  let(:non_owner_attributes) { { business: non_owner_business } }
  let(:record) { Child.create! record_params }

  it_behaves_like 'it lists all records for a user', Child

  it_behaves_like 'it creates a record', Child

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
        let!(:expired_approval) { create(:expired_approval, case_number: '1234567A', create_children: false) }
        let!(:expired_approvals) { create_list(:expired_approval, count, create_children: false) }
        let!(:current_approval) { create(:approval, case_number: '1234567B', create_children: false) }
        let!(:current_approvals) { create_list(:approval, count, create_children: false) }
        let!(:owner_records) { create_list(:child, count, owner_attributes.merge(approvals: [expired_approval, current_approval])) }
        let!(:owner_inactive_records) { create_list(:child, count, owner_attributes.merge(active: false, approvals: [expired_approvals.sample, current_approvals.sample])) }
        let!(:non_owner_records) { create_list(:child, count, non_owner_attributes.merge(approvals: [expired_approvals.sample, current_approvals.sample])) }
        let!(:non_owner_inactive_records) { create_list(:child, count, non_owner_attributes.merge(active: false, approvals: [expired_approvals.sample, current_approvals.sample])) }

        context 'admin user' do
          include_context 'admin user'
          response '200', 'active cases found' do
            run_test! do
              expect(JSON.parse(response.body).size).to eq(count * 2)
              expect(JSON.parse(response.body).first['approvals'].size).to eq(1)
              expect(JSON.parse(response.body).first['approvals'].first['case_number']).to eq('1234567B')
              expect(response).to match_response_schema('case_list_for_dashboard')
            end
          end
        end

        context 'resource owner' do
          before { sign_in owner }

          response '200', 'active cases found' do
            run_test! do
              expect(JSON.parse(response.body).size).to eq(count)
              expect(response).to match_response_schema('case_list_for_dashboard')

              # The below calculations are EXTREMELY WIP
              # Open questions:
              # - if any revenue calculation is negative (because of copay), we should round to 0, should we call it "guaranteed revenue from the state" to make it clear?

              #############
              # Ill Subsidy Rules (for testing purposes)
              # Child age	County	Full day rate	Part day rate Threshold
              # Under 2	  Cook	  39.99	         20           0.495
              # 2	        Cook	  37.26	         18.63        0.495
              # 3+	      Cook	  33.9	         16.95        0.495
              #############
              # on_track, sure_bet, at_risk, not_met, not_enough_info

              #############
              # date of rate calculation: Sep 8th, 2020
              #############

              # Family NoSchoolAgeKids - 30 total approved days, copay $20
              # Child A - 1 year old - 12 part days approved, 5 full days approved, 1 part day and 1 full day attended so far
              # Child B - 3 years old - 8 part days approved, 5 full days approved, 1 part day and 1 full day attended so far

              # attendance_rate = (1 + 1 + 1 + 1) / (12 + 8 + 5 + 5)
              # attendance_risk = 

              # Child A
              # guaranteed_revenue = 
              # potential_revenue = 
              # max_revenue = 

              # Child B
              # guaranteed_revenue = 
              # potential_revenue = 
              # max_revenue = 

              # Child A
              expect(JSON.parse(response.body).first['attendance_rate']).to eq(0.133)
              # expect(JSON.parse(response.body).first['attendance_risk']).to eq()
              # expect(JSON.parse(response.body).first['guaranteed_revenue']).to eq()
              # expect(JSON.parse(response.body).first['potential_revenue']).to eq()
              # expect(JSON.parse(response.body).first['max_revenue']).to eq()

              # Child B
              expect(JSON.parse(response.body)[1]['attendance_rate']).to eq(0.133)
              # expect(JSON.parse(response.body)[1]['attendance_risk']).to eq()
              # expect(JSON.parse(response.body)[1]['guaranteed_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['potential_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['max_revenue']).to eq()

              # Family SchoolAgeKid - 30 total approved days, copay $40
              # Child A - 7 years old - 10 part days approved, 1 part day attended so far
              # Child B - 3 years old - 10 part days approved, 10 full days approved, 1 part day and 1 full day attended so far

              # attendance_rate = (1 + 1 + 1) / (10 + 10 + 10)
              # attendance_risk = 

              # Child A
              # guaranteed_revenue = 
              # potential_revenue = 
              # max_revenue = 

              # Child B
              # guaranteed_revenue = 
              # potential_revenue = 
              # max_revenue = 

              expect(JSON.parse(response.body).first['attendance_rate']).to eq(0.1)
              # expect(JSON.parse(response.body).first['attendance_risk']).to eq()
              # expect(JSON.parse(response.body).first['guaranteed_revenue']).to eq()
              # expect(JSON.parse(response.body).first['potential_revenue']).to eq()
              # expect(JSON.parse(response.body).first['max_revenue']).to eq()
              
              expect(JSON.parse(response.body)[1]['attendance_rate']).to eq(0.1)
              # expect(JSON.parse(response.body)[1]['attendance_risk']).to eq()
              # expect(JSON.parse(response.body)[1]['guaranteed_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['potential_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['max_revenue']).to eq()

              # Family KidAttendsOverApproved - 7 total approved days, copay $33
              # Child A - 6 years old - 7 part days approved, 0 full days approved, 1 part day attended so far

              # attendance_rate = 1 / 7
              # attendance_risk = 

              # Child A
              # guaranteed_revenue = 
              # potential_revenue = 
              # max_revenue = 

              expect(JSON.parse(response.body)[1]['attendance_rate']).to eq(0.143)
              # expect(JSON.parse(response.body)[1]['attendance_risk']).to eq()
              # expect(JSON.parse(response.body)[1]['guaranteed_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['potential_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['max_revenue']).to eq()

              #############
              # date of rate calculation: Sep 21st, 2020
              #############

              # Family NoSchoolAgeKids - 30 total approved days, copay $20
              # Child A - 1 year old - 12 part days approved, 5 full days approved, 7 part days and 3 full days attended so far
              # Child B - 3 years old - 8 part days approved, 5 full days approved, 6 part days and 1 full day attended so far

              # attendance_rate = (7 + 3 + 6 + 1) / (12 + 8 + 5 + 5)
              # attendance_risk = 

              # Child A
              # guaranteed_revenue = 
              # potential_revenue = 
              # max_revenue = 
              
              # Child B
              # guaranteed_revenue = 
              # potential_revenue = 
              # max_revenue = 

              expect(JSON.parse(response.body).first['attendance_rate']).to eq(0.567)
              # expect(JSON.parse(response.body).first['attendance_risk']).to eq("sure_bet")
              # expect(JSON.parse(response.body).first['guaranteed_revenue']).to eq()
              # expect(JSON.parse(response.body).first['potential_revenue']).to eq()
              # expect(JSON.parse(response.body).first['max_revenue']).to eq()

              # Family SchoolAgeKid - 30 total approved days, copay $40
              # Child A - 7 years old - 10 part days approved, 0 full days approved, 3 part days attended so far
              # Child B - 3 years old - 10 part days approved, 10 full days approved, 3 part days and 8 full days attended so far

              # Child A
              # attendance_rate = (3 + 3 + 8) / (10 + 10 + 10)
              # attendance_risk = (14 / [(21/30) * 30]) < 0.495
              # guaranteed_revenue = (3 * 16.25) - 40
              # potential_revenue = (10 * 16.25) - 40
              # max_revenue = (10 * 16.25) - 40

              expect(JSON.parse(response.body)[1]['attendance_rate']).to eq(0.467)
              # expect(JSON.parse(response.body)[1]['attendance_risk']).to eq("on_track")
              # expect(JSON.parse(response.body)[1]['guaranteed_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['potential_revenue']).to eq()
              # expect(JSON.parse(response.body)[1]['max_revenue']).to eq()
            end
          end
        end

        context 'non-owner' do
          include_context 'authenticated user'
          response '200', 'active cases found' do
            run_test! do
              expect(JSON.parse(response.body).size).to eq(0)
            end
          end
        end
      end
    end
  end
end
