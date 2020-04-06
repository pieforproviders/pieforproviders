# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < ApplicationRecord
  # Handles UUIDs breaking ActiveRecord's usual ".first" and ".last" behavior
  self.implicit_order_column = 'created_at'

  belongs_to :user

  validates :active, inclusion: { in: [true, false] }
  validates :date_of_birth, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :full_name, presence: true

  validates_each :date_of_birth do |record, attr, value|
    value.is_a?(Date) ? value : Date.parse(value)
  rescue TypeError, ArgumentError
    record.errors.add(attr, 'Invalid date')
  end
end
