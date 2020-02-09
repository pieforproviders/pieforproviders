# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  it { should have_many(:user_children).dependent(:restrict_with_error) }
  it { should have_many(:users).through(:user_children) }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:user_children) }
end
# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE)
#  date_of_birth :date
#  full_name     :string
#  greeting_name :string
#
