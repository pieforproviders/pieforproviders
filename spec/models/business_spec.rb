# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Business, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:category) }
  it { should validate_inclusion_of(:category).in_array(Business::CATEGORIES) }
end

# == Schema Information
#
# Table name: businesses
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  category   :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_businesses_on_user_id  (user_id)
#
