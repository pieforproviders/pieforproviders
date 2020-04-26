# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < ApplicationRecord
  # Handles UUIDs breaking ActiveRecord's usual ".first" and ".last" behavior
  self.implicit_order_column = 'created_at'

  belongs_to :user

  validates :active, inclusion: { in: [true, false] }
  validates :date_of_birth, presence: true
  validates :full_name, presence: true

  validates_each :date_of_birth do |record, attr, value|
    value.is_a?(Date) ? value : Date.parse(value)
  rescue TypeError, ArgumentError
    record.errors.add(attr, 'Invalid date')
  end

  before_validation { |child| child.slug = generate_slug("#{child.full_name}#{child.date_of_birth}#{child.user_id}") }
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  slug          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ccms_id       :string
#  user_id       :uuid             not null
#
# Indexes
#
#  index_children_on_slug     (slug) UNIQUE
#  index_children_on_user_id  (user_id)
#  unique_children            (full_name,date_of_birth,user_id) UNIQUE
#
