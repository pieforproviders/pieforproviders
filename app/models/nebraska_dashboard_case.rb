# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class NebraskaDashboardCase < UuidApplicationRecord
  belongs_to :child

  scope :for_date,
        lambda { |date = nil, timezone = nil|
          date ||= Time.current
          where(month: date.in_time_zone(timezone).at_beginning_of_month)
        }
end
