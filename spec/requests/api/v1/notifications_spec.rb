# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Notifications', type: :request do
  let!(:admin_user) { create(:confirmed_user, admin: true) }
  let!(:logged_in_user) { create(:confirmed_user, :nebraska) }
  let!(:business) { create(:business, :nebraska_ldds, user: logged_in_user) }
  let!(:approval) { create(:approval, num_children: 3, business: business, expires_on: 3.days.after) }
  let!(:early_approval) { create(:approval, num_children: 1, business: business, expires_on: 1.day.after) }
  let!(:late_approval) { create(:approval, num_children: 1, business: business, expires_on: 29.days.after) }
  let!(:children) { approval.children }
  let!(:early_child) { early_approval.children.first }
  let!(:late_child) { late_approval.children.first }
  let!(:non_owner_child) { create(:necc_child) }

  before do
    approvals = Array.new(3) { |_i| approval }
    approvals << early_approval
    approvals << late_approval
    children << early_child
    children << late_child
    children.length.times { |i| create(:notification, child: children[i], approval: approvals[i]) }
    create(:notification, child: non_owner_child, approval: non_owner_child.approvals.first)
  end

  describe 'GET /api/v1/notifications' do
    include_context 'with correct api version header'

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'returns all notifications' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['first_name'] }).to include(children.first.first_name)
        expect(parsed_response.collect { |x| x['first_name'] }).to include(non_owner_child.first_name)
        expect(response).to match_response_schema('notifications')
      end

      it 'returns notifications in a chronological order' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expires_on_arr = parsed_response.collect { |x| x['expires_on'] }
        expect(expires_on_arr).to eq(expires_on_arr.sort)
      end
    end

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it 'returns the user\'s notifications' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['first_name'] }).to include(children.first.first_name)
        expect(parsed_response.collect { |x| x['first_name'] }).not_to include(non_owner_child.first_name)
        expect(response).to match_response_schema('notifications')
      end

      it 'returns notifications in a chronological order' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expires_on_arr = parsed_response.collect { |x| x['expires_on'] }
        expect(expires_on_arr).to eq(expires_on_arr.sort)
      end
    end
  end
end
