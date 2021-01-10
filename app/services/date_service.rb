# frozen_string_literal: true

# Date helpers for date math and providing values for dropdowns
class DateService
  # how many weeks have days that count as part of this month?
  # i.e. Jan 2021:
  #  M   T   W   R   F   S   S
  #                  1   2   3
  #  4   5   6   7   8   9  10
  # 11 .......................
  # 18 .......................
  # 25  26  27  28  29  30  31
  #
  # there are 5 weeks with days in Jan 2021
  #
  # we do this so we can calculate *APPROXIMATELY* how many
  # attendances kids are allowed per month, because their
  # approval letter will say "4 part days per week", etc.
  # this is a business logic TODO for us once we start to get
  # a better idea of how this works in practice
  def self.weeks_in_month(date)
    (date.to_date.all_month.count / 7.0).ceil
  end
end
