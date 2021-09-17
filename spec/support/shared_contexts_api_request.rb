# frozen_string_literal: true

require 'rails_helper'

VALID_ACCEPT_V1 = 'application/vnd.pieforproviders.v1+json'

RSpec.shared_context 'with correct api version header' do
  let(:headers) { { 'HTTP_ACCEPT' => VALID_ACCEPT_V1 } }
end

RSpec.shared_context 'with incorrect api version header' do
  let(:headers) { { 'HTTP_ACCEPT' => 'application/vnd.pieforproviders.v21+json' } }
end

RSpec.shared_context 'when authenticated' do
  before do
    logged_in_user = create(:confirmed_user)
    sign_in logged_in_user
  end
end

RSpec.shared_context 'when authenticated as an admin' do
  before do
    admin = create(:admin)
    sign_in admin
  end
end
