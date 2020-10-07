# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Business, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:county) }
  it { should belong_to(:zipcode) }
  it { should validate_presence_of(:name) }
  it {
    should define_enum_for(:license_type).with_values(
      Licenses.types
    ).backed_by_column_of_type(:enum)
  }
  it 'validates uniqueness of business name' do
    create(:business)
    should validate_uniqueness_of(:name).scoped_to(:user_id)
  end

  it 'factory should be valid (default; no args)' do
    expect(build(:business)).to be_valid
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id           :uuid             not null, primary key
#  active       :boolean          default(TRUE), not null
#  license_type :enum
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  county_id    :uuid             not null
#  user_id      :uuid             not null
#  zipcode_id   :uuid             not null
#
# Indexes
#
#  index_businesses_on_county_id         (county_id)
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_user_id           (user_id)
#  index_businesses_on_zipcode_id        (zipcode_id)
#
# Foreign Keys
#
#  fk_rails_...  (county_id => counties.id)
#  fk_rails_...  (zipcode_id => zipcodes.id)
#
