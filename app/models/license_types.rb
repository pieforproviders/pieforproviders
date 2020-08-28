# frozen_string_literal: true

# License types
# These are the list of valid license types.
# These correspond to an ENUM type defined in the Postgres DB
class LicenseTypes
  LICENSE_TYPES = %w[licensed_center
                     licensed_family_home
                     licensed_group_home
                     license_exempt_home
                     license_exempt_center].freeze

  def self.valid_types
    LICENSE_TYPES.to_h { |s| [s.to_sym, s] }
  end
end
