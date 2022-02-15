# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Payments', type: :request do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:business) { create(:business, user: logged_in_user) }

  let!(:approval_sept) do
      create(:approval, effective_on: Date.parse('2021-09-01'), business: business, create_children: false)
    end
    let!(:approval_oct) do
      create(:approval, effective_on: Date.parse('2021-10-01'), business: business, create_children: false)
    end
  let!(:child) { create(:child, approvals: [approval_sept, approval_oct], business: business) }

  let!(:current_month) { Time.zone.local(2021, 9, 15) } # September
  let!(:start_of_month) { current_month.at_beginning_of_month } # Start of September
  let!(:end_of_month) { current_month.at_end_of_month } # End of September

  let!(:three_months_before_current_month) { current_month - 3.months } # June
  let!(:one_months_before_current_month) { current_month - 1.months } # August

  let!(:this_month_payments) do
    month = Faker::Time.between(from: start_of_month, to: end_of_month)

    create_list(:payment, 3, child_approval: child.child_approvals.first, month: month)
  end

  let!(:past_payments) do
      month = Faker::Time.between(from: three_months_before_current_month, to: one_months_before_current_month)

      create_list(:payment, 2, child_approval: child.child_approvals.first, month: month)
    end

  let!(:extra_payments) do
    create_list(:payment, 3, month: Faker::Time.between(from: start_of_month, to: end_of_month))
  end

  describe 'GET /api/v1/payments' do
    include_context 'with correct api version header'

    before do
      travel_to current_month
      sign_in logged_in_user
    end

    after { travel_back }

    context 'when sent with a filter date' do
      let(:params) { { filter_date: current_month } }

      it 'displays the payments' do
        get '/api/v1/payments', params: params, headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect do |x|
                 x['child_approval_id']
               end).to match_array(this_month_payments.collect(&:child_approval_id))
        expect(parsed_response.collect do |x|
                 x['amount']
               end).to match_array(this_month_payments.collect { |x| x.amount.to_s })
        expect(parsed_response.collect do |x|
                 x['month']
               end).to match_array(this_month_payments.collect { |x| x.month.to_s })
        expect(parsed_response.length).to eq(3)
        expect(response).to match_response_schema('payments')
      end
    end

    context 'when sent without a filter date' do
      it 'displays the payments' do
        get '/api/v1/payments', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        user_payments = this_month_payments + past_payments
        expect(parsed_response.collect do |x|
                 x['child_approval_id']
               end).to match_array(user_payments.collect(&:child_approval_id))
        expect(parsed_response.collect do |x|
                 x['amount']
               end).to match_array(user_payments.collect { |x| x.amount.to_s })
        expect(parsed_response.collect do |x|
                 x['month']
               end).to match_array(user_payments.collect { |x| x.month.to_s })
        expect(parsed_response.length).to eq(5)
        expect(response).to match_response_schema('payments')
      end
    end

    context 'when viewed by an admin' do
      before do
        admin = create(:admin)
        sign_in admin
      end

      it 'displays the payments' do
        get '/api/v1/payments', params: {}, headers: headers
        parsed_response = JSON.parse(response.body)
        all_current_payments = this_month_payments + past_payments + extra_payments
        expect(parsed_response.collect do |x|
                 x['child_approval_id']
               end).to match_array(all_current_payments.collect(&:child_approval_id))
        expect(parsed_response.collect do |x|
                 x['amount']
               end).to match_array(all_current_payments.collect { |x| x.amount.to_s })
        expect(parsed_response.collect do |x|
                 x['month']
               end).to match_array(all_current_payments.collect { |x| x.month.to_s })
        expect(parsed_response.length).to eq(8)
        expect(response).to match_response_schema('payments')
      end
    end
  end
end
