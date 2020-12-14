# frozen_string_literal: true

require 'rails_helper'

VALID_ACCEPT_V1 = 'application/vnd.pieforproviders.v1+json'

RSpec.shared_context 'correct api version header' do
  let!(:Accept) { VALID_ACCEPT_V1 }
  let!(:headers) { { 'HTTP_ACCEPT' => VALID_ACCEPT_V1 } }
end

RSpec.shared_context 'incorrect api version header' do
  let!(:Accept) { 'application/vnd.pieforproviders.v21+json' }
  let(:headers) { { 'HTTP_ACCEPT' => 'application/vnd.pieforproviders.v21+json' } }
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

RSpec.shared_context 'il_family_no_school_age_kids' do
  let!(:business) { create(:business) }
  let!(:evie_subsidy_rule) { create(:subsidy_rule_for_illinois, max_age: 18) }
  let!(:eli_subsidy_rule) { create(:subsidy_rule_for_illinois, max_age: 1) }
  let!(:approval) { create(:approval, create_children: false) }
  let!(:evie) { create(:child, date_of_birth: Faker::Date.birthday(min_age: 3, max_age: 5).strftime('%Y-%m-%d'), business: business, approvals: [approval]) }
  let!(:eli) { create(:child, date_of_birth: Faker::Date.birthday(min_age: 0, max_age: 1).strftime('%Y-%m-%d'), business: business, approvals: [approval]) }
end
