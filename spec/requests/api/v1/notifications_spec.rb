# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Notifications', type: :request do
  let!(:admin_user) { create(:confirmed_user, admin: true) }
  let!(:logged_in_user) { create(:confirmed_user, :nebraska) }
  let!(:business) { create(:business, :nebraska_ldds, user: logged_in_user) }
  let!(:approval) { create(:approval, num_children: 3, business: business) }
  let!(:children) { approval.children }
  let!(:non_owner_child) { create(:necc_child) }

  before do
    create(:notification, child: children.first, approval: approval)
    create(:notification, child: non_owner_child, approval: non_owner_child.approvals.first)
  end

  describe 'GET /api/v1/notifications' do
    include_context 'with correct api version header'

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'returns the all notifications' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.collect { |x| x['first_name'] }).to include(children.first.first_name)
        expect(parsed_response.collect { |x| x['first_name'] }).to include(non_owner_child.first_name)
        expect(response).to match_response_schema('notifications')
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
    end
  end
end
