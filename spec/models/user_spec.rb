# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:user_children).dependent(:restrict_with_error) }
  it { should have_many(:children).through(:user_children) }
  it { should validate_presence_of(:email) }

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
#  phone                      :string
#  service_agreement_accepted :boolean          default(FALSE), not null
#  timezone                   :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
