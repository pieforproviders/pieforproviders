# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Children' do
  let!(:logged_in_user) { create(:confirmed_user) }
  let!(:user_business) { create(:business_with_children, user: logged_in_user) }
  let!(:second_user_business) { create(:business_with_children, user: logged_in_user) }
  let!(:business_children) { user_business.children }
  let!(:second_business_children) { second_user_business.children }
  let!(:other_business) { create(:business_with_children) }
  let!(:other_business_children) { other_business.children }
  let!(:admin_user) { create(:confirmed_user, admin: true) }
  let(:child) { create(:child) }
  let(:approval) { create(:approval, child:, effective_on: '2020-01-01', expires_on: '2020-12-31') }

  describe 'GET /api/v1/children' do
    include_context 'with correct api version header'

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "returns the user's children" do
        get('/api/v1/children', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*second_business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*other_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(response).to match_response_schema('children')
      end

      it 'returns the correct children when a business filter is sent' do
        get '/api/v1/children', headers:, params: { business: [user_business.id] }
        parsed_response = response.parsed_body
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*second_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*other_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(response).to match_response_schema('children')
      end

      it 'returns the correct children when multiple businesses are sent in the filter' do
        get '/api/v1/children', headers:, params: { business: [user_business.id, other_business.id] }
        parsed_response = response.parsed_body
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*second_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*other_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(response).to match_response_schema('children')
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "returns all users' children" do
        get('/api/v1/children', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*second_business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*other_business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(response).to match_response_schema('children')
      end

      it 'returns the correct children when a business filter is sent' do
        get '/api/v1/children', headers:, params: { business: [user_business.id] }
        parsed_response = response.parsed_body
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*second_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*other_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(response).to match_response_schema('children')
      end

      it 'returns the correct children when multiple businesses are sent in the filter' do
        get '/api/v1/children', headers:, params: { business: [user_business.id, other_business.id] }
        parsed_response = response.parsed_body
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*business_children.map do |c|
                                 [c.first_name, c.last_name].join(' ')
                               end)
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).not_to include(*second_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(parsed_response.collect do |x|
                 "#{x['first_name']} #{x['last_name']}"
               end).to include(*other_business_children.map { |c| [c.first_name, c.last_name].join(' ') })
        expect(response).to match_response_schema('children')
      end

      it 'returns the children ordered by last names' do
        create(:child, last_name: 'zzzz')
        get('/api/v1/children', headers:)
        parsed_response = response.parsed_body
        expect(parsed_response.last['last_name']).to eq('zzzz')
      end
    end
  end

  describe 'GET /api/v1/children/:id' do
    include_context 'with correct api version header'

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "returns the user's child" do
        get("/api/v1/children/#{business_children.first.id}", headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq([
          business_children.first.first_name, business_children.first.last_name
        ].join(' '))
        expect(response).to match_response_schema('child')
      end

      it 'does not return a child for another user' do
        get("/api/v1/children/#{other_business_children.first.id}", headers:)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "returns the user's child" do
        get("/api/v1/children/#{business_children.first.id}", headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq([
          business_children.first.first_name, business_children.first.last_name
        ].join(' '))
        expect(response).to match_response_schema('child')
      end

      it 'returns a child for another user' do
        get("/api/v1/children/#{other_business_children.first.id}", headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq([
          other_business_children.first.first_name, other_business_children.first.last_name
        ].join(' '))
        expect(response).to match_response_schema('child')
      end
    end
  end

  describe 'POST /api/v1/children' do
    include_context 'with correct api version header'

    let(:params) do
      {
        child: {
          first_name: 'Parvati',
          last_name: 'Patil',
          date_of_birth: '1981-04-09',
          business_id: user_business.id,
          approvals_attributes: [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
        }
      }
    end
    let(:params_without_business) { { child: params[:child].except(:business_id) } }

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "creates a child for that user's business" do
        post('/api/v1/children', params:, headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq('Parvati Patil')
        expect(logged_in_user.children.map { |c| [c.first_name, c.last_name].join(' ') }).to include('Parvati Patil')
        expect(response).to match_response_schema('child')
      end

      context 'when logged in as a nebraska user' do
        let(:nebraska_business) do
          create(:business, :nebraska_ldds, user: create(:confirmed_user, :nebraska))
        end

        before { sign_in nebraska_business.user }

        it "creates a child for that user's business" do
          params[:child][:business_id] = nebraska_business.id
          post('/api/v1/children', params:, headers:)
          parsed_response = response.parsed_body
          expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq('Parvati Patil')
          expect(nebraska_business.children.map do |c|
                   [c.first_name, c.last_name].join(' ')
                 end).to include('Parvati Patil')
          expect(response).to match_response_schema('child')
        end
      end

      context 'when including illinois approved amounts in params' do
        let(:params) do
          {
            child: {
              first_name: 'Parvati',
              last_name: 'Patil',
              date_of_birth: '1981-04-09',
              business_id: user_business.id,
              approvals_attributes: [attributes_for(:approval).merge!({ effective_on: Date.parse('Mar 22, 2020') })]
            },
            first_month_name: 'March',
            first_month_year: '2020'
          }
        end
        let(:one_month_amount) do
          params.merge(month1:
            {
              part_days_approved_per_week: 4,
              full_days_approved_per_week: 1
            })
        end
        let(:some_month_amounts) do
          6.times do |x|
            params["month#{x + 1}"] = {
              part_days_approved_per_week: 3,
              full_days_approved_per_week: 2
            }
          end
          params
        end
        let(:all_month_amounts) do
          12.times do |x|
            params["month#{x + 1}"] = {
              part_days_approved_per_week: 3,
              full_days_approved_per_week: 2
            }
          end
          params
        end

        it 'does not create approval amounts when no month is passed' do
          post('/api/v1/children', params:, headers:)
          expect(response).to have_http_status(:created)
          json = response.parsed_body
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts).to be_empty
          expect(response).to match_response_schema('child')
        end

        it 'creates 12 approval amounts when a single month is passed' do
          post('/api/v1/children', params: one_month_amount, headers:)
          expect(response).to have_http_status(:created)
          json = response.parsed_body
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(12)
          expect(child.child_approvals.first.illinois_approval_amounts.pluck(:month)).to include(
            Date.parse("#{one_month_amount[:first_month_name]} #{one_month_amount[:first_month_year]}")
          )
          expect(response).to match_response_schema('child')
        end

        it 'creates 12 approval amounts when 12 months are passed' do
          post('/api/v1/children', params: all_month_amounts, headers:)
          expect(response).to have_http_status(:created)
          json = response.parsed_body
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(12)
          expect(child.child_approvals.first.illinois_approval_amounts.pluck(:month)).to include(
            Date.parse("#{all_month_amounts[:first_month_name]} #{all_month_amounts[:first_month_year]}")
          )
          expect(response).to match_response_schema('child')
        end

        it 'creates exactly the number of approval amounts passed when the number is between 1 and 12' do
          post('/api/v1/children', params: some_month_amounts, headers:)
          expect(response).to have_http_status(:created)
          json = response.parsed_body
          child = Child.find(json['id'])
          expect(child.child_approvals.first.illinois_approval_amounts.length).to eq(6)
          expect(child.child_approvals.first.illinois_approval_amounts.pluck(:month)).to include(
            Date.parse("#{some_month_amounts[:first_month_name]} #{some_month_amounts[:first_month_year]}")
          )
          expect(response).to match_response_schema('child')
        end
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it 'creates a child for the passed business' do
        post('/api/v1/children', params:, headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq('Parvati Patil')
        expect(logged_in_user.children.map { |c| [c.first_name, c.last_name].join(' ') }).to include('Parvati Patil')
        expect(response).to match_response_schema('child')
      end

      it 'fails unless the business is passed' do
        post('/api/v1/children', params: params_without_business, headers:)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /api/v1/children/:id' do
    include_context 'with correct api version header'

    let(:params) do
      {
        child: {
          first_name: 'Padma',
          last_name: 'Patil'
        }
      }
    end

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "updates the user's child" do
        put("/api/v1/children/#{business_children.first.id}", params:, headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq('Padma Patil')
        business_children.first.reload
        expect("#{business_children.first.first_name} #{business_children.first.last_name}").to eq('Padma Patil')
        expect(response).to match_response_schema('child')
      end

      it 'does not update a child for another user' do
        put("/api/v1/children/#{other_business_children.first.id}", params:, headers:)
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error if the data is invalid' do
        params = {
          child: {
            date_of_birth: 'Not a date'
          }
        }
        put("/api/v1/children/#{business_children.first.id}", params:, headers:)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'can update an inactive child to active' do
        business_children.first.update!(active: false)
        param = {
          child: {
            active: true
          }
        }
        put("/api/v1/children/#{business_children.first.id}", params: param, headers:)
        business_children.first.reload
        expect(business_children.first.active).to be true
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "updates the user's child" do
        put("/api/v1/children/#{business_children.first.id}", params:, headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq('Padma Patil')
        business_children.first.reload
        expect("#{business_children.first.first_name} #{business_children.first.last_name}").to eq('Padma Patil')
        expect(response).to match_response_schema('child')
      end

      it 'updates a child for another user' do
        put("/api/v1/children/#{other_business_children.first.id}", params:, headers:)
        parsed_response = response.parsed_body
        expect("#{parsed_response['first_name']} #{parsed_response['last_name']}").to eq('Padma Patil')
        other_business_children.first.reload
        expect("#{other_business_children.first.first_name} #{other_business_children.first.last_name}")
          .to eq('Padma Patil')
        expect(response).to match_response_schema('child')
      end
    end
  end

  describe 'DELETE /api/v1/children/:id' do
    include_context 'with correct api version header'

    context 'when logged in as a non-admin user' do
      before { sign_in logged_in_user }

      it "soft-deletes the user's child" do
        delete("/api/v1/children/#{business_children.first.id}", headers:)
        expect(response).to have_http_status(:no_content)
        expect(business_children.first.reload.deleted_at).to eq(Time.current.to_date)
      end
    end

    context 'when logged in as an admin user' do
      before { sign_in admin_user }

      it "soft-deletes the user's child" do
        delete("/api/v1/children/#{business_children.first.id}", headers:)
        expect(response).to have_http_status(:no_content)
        expect(business_children.first.reload.deleted_at).to eq(Time.current.to_date)
      end
    end
  end

  describe 'PATCH /children/:id/update_auth' do
    include_context 'with correct api version header'

    context 'when logged in as an admin user' do
      before do
        sign_in admin_user
      end

      it "updates child's approval" do
        approval = child.approvals.first
        current_effective_date = approval.effective_on.to_s
        current_expiration_date = approval.expires_on.to_s

        data = {
          current_effective_date:,
          current_expiration_date:,
          new_effective_date: '2023-05-01',
          new_expiration_date: '2024-05-31'
        }

        patch("/api/v1/children/#{child.id}/update_auth", headers:, params: data)
        expect(response).to have_http_status(:ok)

        approval.reload

        expect(approval.effective_on.to_s).to eq('2023-05-01')
        expect(approval.expires_on.to_s).to eq('2024-05-31')
      end
    end
  end
end
