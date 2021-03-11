# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:confirmed_user) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:greeting_name) }
  it { should validate_presence_of(:language) }
  it { should validate_presence_of(:organization) }
  it { should validate_uniqueness_of(:phone_number).ignoring_case_sensitivity }
  it { should validate_presence_of(:timezone) }
  it { should validate_presence_of(:service_agreement_accepted) }

  it 'factory should be valid (default; no args)' do
    expect(build(:confirmed_user)).to be_valid
    expect(build(:unconfirmed_user)).to be_valid
    expect(build(:admin)).to be_valid
  end

  let(:user) { create(:confirmed_user, phone_number: '888-888-8888') }
  it 'formats a phone number with non-digit characters' do
    expect(user.phone_number).to eq('8888888888')
  end

  describe '#first_approval_effective_date' do
    let!(:business) { create(:business, user: user) }
    let!(:approval1) { create(:approval, effective_on: Date.parse('Mar 3, 2020'), create_children: false) }
    let!(:approval2) { create(:approval, effective_on: Date.parse('Jan 10, 2020'), create_children: false) }
    let!(:approval3) { create(:approval, effective_on: Date.parse('May 6, 2020'), create_children: false) }
    let!(:approval4) { create(:approval, effective_on: Date.parse('Feb 21, 2020'), create_children: false) }
    let!(:child) { create(:child, business: business, approvals: [approval1, approval2, approval3]) }
    let!(:child2) { create(:child, business: business, approvals: [approval4]) }
    it 'returns the correct date' do
      expect(user.first_approval_effective_date).to eq(Date.parse('Jan 10, 2020'))
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  active                     :boolean          default(TRUE), not null
#  admin                      :boolean          default(FALSE), not null
#  confirmation_sent_at       :datetime
#  confirmation_token         :string
#  confirmed_at               :datetime
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :string           not null
#  encrypted_password         :string           default(""), not null
#  full_name                  :string           not null
#  greeting_name              :string           not null
#  language                   :string           not null
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  opt_in_email               :boolean          default(TRUE), not null
#  opt_in_text                :boolean          default(TRUE), not null
#  organization               :string           not null
#  phone_number               :string
#  phone_type                 :string
#  remember_created_at        :datetime
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  service_agreement_accepted :boolean          default(FALSE), not null
#  sign_in_count              :integer          default(0), not null
#  timezone                   :string           not null
#  unconfirmed_email          :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_phone_number          (phone_number) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token)
#
