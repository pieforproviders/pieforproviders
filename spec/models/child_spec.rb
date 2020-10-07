# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:date_of_birth) }

  it 'factory should be valid (default; no args)' do
    expect(build(:child)).to be_valid
  end

  it 'validates uniqueness of full name' do
    create(:child)
    should validate_uniqueness_of(:full_name).scoped_to(:date_of_birth, :user_id)
  end
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ccms_id       :string
#  user_id       :uuid             not null
#
# Indexes
#
#  index_children_on_user_id  (user_id)
#  unique_children            (full_name,date_of_birth,user_id) UNIQUE
#
