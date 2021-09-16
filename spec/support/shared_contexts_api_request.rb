# frozen_string_literal: true

require 'rails_helper'

VALID_ACCEPT_V1 = 'application/vnd.pieforproviders.v1+json'

RSpec.shared_context 'correct api version header' do
  # rubocop:disable RSpec/LetSetup
  # rubocop:disable RSpec/VariableName
  let!(:Accept) { VALID_ACCEPT_V1 }
  # rubocop:enable RSpec/VariableName
  let!(:headers) { { 'HTTP_ACCEPT' => VALID_ACCEPT_V1 } }
  # rubocop:enable RSpec/LetSetup
end

RSpec.shared_context 'incorrect api version header' do
  # rubocop:disable RSpec/LetSetup
  # rubocop:disable RSpec/VariableName
  let!(:Accept) { 'application/vnd.pieforproviders.v21+json' }
  # rubocop:enable RSpec/VariableName
  let(:headers) { { 'HTTP_ACCEPT' => 'application/vnd.pieforproviders.v21+json' } }
  # rubocop:enable RSpec/LetSetup
end

RSpec.shared_context 'authenticated user' do
  before do
    logged_in_user = create(:confirmed_user)
    sign_in logged_in_user
  end
end

RSpec.shared_context 'admin user' do
  before do
    admin = create(:admin)
    sign_in admin
  end
end
