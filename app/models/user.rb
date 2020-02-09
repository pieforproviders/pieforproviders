# frozen_string_literal: true

# Application users
class User < ApplicationRecord
  has_many :user_children, dependent: :restrict_with_error
  has_many :children, through: :user_children

  validates :email, presence: true

  # format phone numbers - remove any non-digit characters
  def phone=(value)
    super(value.blank? ? nil : value.gsub(/[^\d]/, ''))
  end
end
# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  active                     :boolean          default(TRUE)
#  county                     :string
#  date_of_birth              :date
#  email                      :string
#  full_name                  :string
#  greeting_name              :string
#  language                   :string
#  okay_to_email              :boolean          default(TRUE)
#  okay_to_phone              :boolean          default(TRUE)
#  okay_to_text               :boolean          default(TRUE)
#  opt_in_email               :boolean          default(TRUE)
#  opt_in_phone               :boolean          default(TRUE)
#  opt_in_text                :boolean          default(TRUE)
#  phone                      :string
#  service_agreement_accepted :boolean          default(TRUE)
#  timezone                   :string
#  zip                        :string
#
