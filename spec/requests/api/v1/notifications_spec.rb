# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Notifications' do
  let!(:admin_user) { create(:confirmed_user, admin: true) }
  let!(:logged_in_user) { create(:confirmed_user, :nebraska) }
  let!(:business) { create(:business, :nebraska_ldds, user: logged_in_user, active: true) }
  let!(:approval) { create(:approval, num_children: 1, business: business, expires_on: 3.days.after) }
  let!(:early_approval) { create(:approval, num_children: 1, business: business, expires_on: 1.day.after) }
  let!(:late_approval) { create(:approval, num_children: 1, business: business, expires_on: 29.days.after) }
  let!(:children) { [approval.children.first, early_child, late_child] }
  let!(:early_child) { early_approval.children.first }
  let!(:late_child) { late_approval.children.first }
  let!(:non_owner_child) { create(:necc_child) }

  before do
    approvals = [approval, early_approval, late_approval]
    children.length.times { |i| create(:notification, child: children[i], approval: approvals[i]) }
    create(:notification, child: non_owner_child, approval: non_owner_child.approvals.first)
  end

  describe 'GET /api/v1/notifications/::id' do
    include_context 'with correct api version header'

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'gets the notification by id' do
        get "/api/v1/notifications/#{children.first.notifications.first.id}", params: {}, headers: headers
        expect(response).to match_response_schema('notification')
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['first_name']).to eq(children.first.first_name)
      end

      it 'returns not found when notification does not exist' do
        notify = children.first.notifications.first
        notify.destroy
        get "/api/v1/notifications/#{notify.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as a non-admin' do
      before { sign_in logged_in_user }

      it 'gets the notification by id' do
        get "/api/v1/notifications/#{children.first.notifications.first.id}", params: {}, headers: headers
        expect(response).to match_response_schema('notification')
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['first_name']).to eq(children.first.first_name)
      end

      it 'returns not found when notification does not exist' do
        notify = children.first.notifications.first
        notify.destroy
        get "/api/v1/notifications/#{notify.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found when notification is within the scope of the user' do
        get "/api/v1/notifications/#{non_owner_child.notifications.first.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/notifications' do
    include_context 'with correct api version header'
    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'creates a notification for an existing child and approval' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 3.days.after)
        child = existing_approval.children.first
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to match_response_schema('notification')
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['first_name']).to eq(child.first_name)
      end

      it 'returns an error if the child does not exist' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        child = existing_approval.children.first
        child.destroy
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if the approval does not exist' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        child = existing_approval.children.first
        existing_approval.destroy
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if the approval does not belong to child' do
        approval_one = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        approval_two = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        child = approval_two.children.first
        params = { notification: { child_id: child.id, approval_id: approval_one.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if approval is expired' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 1.day.before)
        child = existing_approval.children.first
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error if approval has been renewed recently' do
        child = create(:necc_child)
        params = { notification: { child_id: child.id, approval_id: child.approvals.first.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when logged in as a non admin' do
      before { sign_in logged_in_user }

      it 'returns an error if approval has been renewed recently' do
        child = children.first
        params = { notification: { child_id: child.id, approval_id: child.approvals.first.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'creates a notification for an existing child and approval' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 3.days.after)
        child = existing_approval.children.first
        logged_in_user.reload
        existing_approval.reload
        child.reload
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to match_response_schema('notification')
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['first_name']).to eq(child.first_name)
      end

      it 'returns an error if the child does not exist' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        child = existing_approval.children.first
        child.destroy
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if the approval does not exist' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        child = existing_approval.children.first
        existing_approval.destroy
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if the approval does not belong to child' do
        approval_one = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        approval_two = create(:approval, num_children: 1, business: business, expires_on: 1.day.after)
        child = approval_two.children.first
        params = { notification: { child_id: child.id, approval_id: approval_one.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if approval is expired' do
        existing_approval = create(:approval, num_children: 1, business: business, expires_on: 1.day.before)
        child = existing_approval.children.first
        params = { notification: { child_id: child.id, approval_id: existing_approval.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error if the child is not within the scope of the user' do
        params = { notification: { child_id: non_owner_child.id, approval_id: non_owner_child.approvals.first.id } }
        post '/api/v1/notifications', params: params, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/notifications' do
    include_context 'with correct api version header'
    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'deletes the notification' do
        delete "/api/v1/notifications/#{children.first.notifications.first.id}", params: {}, headers: headers
        expect(response).to have_http_status(:no_content)
      end

      it 'returns error if notification does not exist' do
        does_not_exist = children.first.notifications.first
        does_not_exist.destroy
        delete "/api/v1/notifications/#{does_not_exist.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as a non-admin' do
      before { sign_in logged_in_user }

      it 'returns error if notification is not within scope of user' do
        delete "/api/v1/notifications/#{non_owner_child.notifications.first.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error if notification does not exist' do
        does_not_exist = children.first.notifications.first
        does_not_exist.destroy
        delete "/api/v1/notifications/#{does_not_exist.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'deletes the notification if it is within the scope of the user' do
        delete "/api/v1/notifications/#{children.first.notifications.first.id}", params: {}, headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'PUT /api/v1/notifications' do
    include_context 'with correct api version header'
    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'updates the notification' do
        new_time = Time.current.at_beginning_of_day
        params = { notification: { created_at: new_time } }
        put "/api/v1/notifications/#{children.first.notifications.first.id}", params: params, headers: headers
        resp = JSON.parse(response.body)
        expect(resp['created_at']).to eq(new_time.to_s)
      end

      it 'returns error if notifictaion does not exist' do
        does_not_exist = children.first.notifications.first
        does_not_exist.destroy
        put "/api/v1/notifications/#{does_not_exist.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as a non-admin' do
      before { sign_in logged_in_user }

      it 'returns error if notifictaion does not exist' do
        does_not_exist = children.first.notifications.first
        does_not_exist.destroy
        put "/api/v1/notifications/#{does_not_exist.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error if notification is not within scope of user' do
        put "/api/v1/notifications/#{non_owner_child.notifications.first.id}", params: {}, headers: headers
        expect(response).to have_http_status(:not_found)
      end

      it 'updates the notification if is in the scope of the user' do
        new_time = Time.current.at_beginning_of_day
        params = { notification: { created_at: new_time } }
        put "/api/v1/notifications/#{children.first.notifications.first.id}", params: params, headers: headers
        resp = JSON.parse(response.body)
        expect(resp['created_at']).to eq(new_time.to_s)
      end
    end
  end

  describe 'GET /api/v1/notifications' do
    include_context 'with correct api version header'

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'returns all notifications' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.pluck('first_name')).to include(children.first.first_name)
        expect(parsed_response.pluck('first_name')).to include(non_owner_child.first_name)
        expect(response).to match_response_schema('notifications')
      end

      it 'returns notifications in a chronological order' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expires_on_arr = parsed_response.pluck('expires_on')
        expect(expires_on_arr).to eq(expires_on_arr.sort)
      end
    end

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it 'returns the user\'s notifications' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expect(parsed_response.pluck('first_name')).to include(children.first.first_name)
        expect(parsed_response.pluck('first_name')).not_to include(non_owner_child.first_name)
        expect(response).to match_response_schema('notifications')
      end

      it 'returns notifications in a chronological order' do
        get '/api/v1/notifications', headers: headers
        parsed_response = JSON.parse(response.body)
        expires_on_arr = parsed_response.pluck('expires_on')
        expect(expires_on_arr).to eq(expires_on_arr.sort)
      end
    end
  end
end
