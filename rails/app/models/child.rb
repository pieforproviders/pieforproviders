# frozen_string_literal: true

# Children receiving care
class Child < ApplicationRecord
  has_many :user_children, dependent: :restrict_with_error
  has_many :users, through: :user_children

  validates :user_children, :full_name, presence: true
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
