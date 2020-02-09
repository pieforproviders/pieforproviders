# frozen_string_literal: true

# Time Zone helpers for date math and providing values for dropdowns
class TimeZoneService
  def self.us_zones
    ActiveSupport::TimeZone.us_zones.map { |zone| Time.now.in_time_zone(zone).strftime('%Z') }.uniq
  end
end
