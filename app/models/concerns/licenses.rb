# frozen_string_literal: true

# Business Licenses that Childcare Providers may hold, that impact which subsidy rule is applied
module Licenses
  extend ActiveSupport::Concern

  TYPES = %w[
    licensed_center
    licensed_family_home
    licensed_group_home
    license_exempt_home
    license_exempt_center
    family_child_care_home_i
    family_child_care_home_ii
    family_in_home
  ].freeze

  included do
    validates :license_type, inclusion: { in: TYPES }, allow_nil: true
  end
end
