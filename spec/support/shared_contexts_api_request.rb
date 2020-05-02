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

RSpec.shared_context 'authenticated user' do
  before do
    logged_in_user = create(:user)
    sign_in logged_in_user
  end
end
