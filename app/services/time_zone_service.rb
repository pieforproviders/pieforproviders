# frozen_string_literal: true

# Time Zone helpers for date math and providing values for dropdowns
class TimeZoneService
  def self.us_zones
    ActiveSupport::TimeZone.us_zones.map(&:name).uniq
  end
end
