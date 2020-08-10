# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Site, type: :model do
  it { should belong_to(:business) }
  it { should have_many(:child_sites) }
  it { should have_many(:children).through(:child_sites) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:state) }
  it { should validate_presence_of(:zip) }
  it { should validate_presence_of(:county) }
  it 'validates uniqueness of site name' do
    create(:site)
    should validate_uniqueness_of(:name).scoped_to(:business_id)
  end
end

# == Schema Information
#
# Table name: sites
#
#  id          :uuid             not null, primary key
#  active      :boolean          default(TRUE), not null
#  address     :string           not null
#  city        :string           not null
#  county      :string           not null
#  name        :string           not null
#  qris_rating :string
#  slug        :string           not null
#  state       :string           not null
#  zip         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#
# Indexes
#
#  index_sites_on_name_and_business_id  (name,business_id) UNIQUE
#
