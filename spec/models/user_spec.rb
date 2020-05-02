# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:language) }
  it { should validate_presence_of(:organization) }
  it { should validate_presence_of(:timezone) }

  let!(:user) { create(:user, phone: '888-888-8888') }
  it 'formats a phone number with non-digit characters' do
    expect(user.phone).to eq('8888888888')
  end
end
# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  active                     :boolean          default(TRUE), not null
#  email                      :string           not null
#  full_name                  :string           not null
#  greeting_name              :string
#  language                   :string           not null
#  mobile                     :string
#  opt_in_email               :boolean          default(TRUE), not null
#  opt_in_phone               :boolean          default(TRUE), not null
#  opt_in_text                :boolean          default(TRUE), not null
#  organization               :string           not null
#  phone                      :string
#  service_agreement_accepted :boolean          default(FALSE), not null
#  slug                       :string           not null
#  timezone                   :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_slug   (slug) UNIQUE
#
