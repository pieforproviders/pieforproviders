# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class Business < ApplicationRecord
  
  CATEGORIES = %w[
    licensed_center_single
    licensed_center_multi
    licensed_family_home
    licensed_group_home
    license_exempt_home
    license_exempt_center_single
    license_exempt_center_multi
  ].freeze

  # Handles UUIDs breaking ActiveRecord's usual ".first" and ".last" behavior
  self.implicit_order_column = 'created_at'

  belongs_to :user

  validates :name, presence: true
  validates :category, presence: true
  validates :category, inclusion: { in: CATEGORIES }

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
