# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'correct api version header' do
  let!(:Accept) { 'application/vnd.pieforproviders.v1+json' }
  let(:headers) { { 'HTTP_ACCEPT' => 'application/vnd.pieforproviders.v1+json' } }
end
RSpec.shared_context 'incorrect api version header' do
  let!(:Accept) { 'application/vnd.pieforproviders.v21+json' }
  let(:headers) { { 'HTTP_ACCEPT' => 'application/vnd.pieforproviders.v21+json' } }
end

# RSpec.shared_context 'authenticated user' do
#   before do
#     logged_in_user = create(:user)
#     post '/oauth/token', params: { email: logged_in_user.email, password: logged_in_user.password, grant_type: 'password' }
#     @token = json['access_token']
#     headers.merge!('HTTP_AUTHORIZATION' => "Bearer #{@token}")
#   end
#   let!(:Authorization) { "Bearer #{@token}" }
# end

# RSpec.shared_context 'unauthenticated user' do
#   headers ||= {}
#   headers.merge!('HTTP_AUTHORIZATION' => 'Bearer fish-fingers-and-custard')
#   let!(:Authorization) { 'Bearer fish-fingers-and-custard' }
# end
