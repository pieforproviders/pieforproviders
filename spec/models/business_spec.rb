# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Business, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:category) }
  it { should validate_inclusion_of(:category).in_array(Business::CATEGORIES) }
  it 'validates uniqueness of business name' do
    create(:business)
    should validate_uniqueness_of(:name).scoped_to(:user_id)
  end
end

# == Schema Information
#
# Table name: businesses
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  category   :string           not null
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_slug              (slug) UNIQUE
#  index_businesses_on_user_id           (user_id)
#
