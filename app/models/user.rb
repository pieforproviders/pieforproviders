# frozen_string_literal: true

# Application users
class User < ApplicationRecord

  validates :active, inclusion: { in: [true, false] }
  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :language, presence: true
  validates :opt_in_text, inclusion: { in: [true, false] }
  validates :opt_in_email, inclusion: { in: [true, false] }
  validates :opt_in_phone, inclusion: { in: [true, false] }
  validates :service_agreement_accepted, inclusion: { in: [true, false] }
  validates :timezone, presence: true

  # format phone numbers - remove any non-digit characters
  def phone=(value)
    super(value.blank? ? nil : value.gsub(/[^\d]/, ''))
  end
end