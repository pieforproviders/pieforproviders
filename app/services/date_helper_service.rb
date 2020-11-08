# frozen_string_literal: true

# Date helpers for calculations, including leap days
class DateHelperService
  #
  # @return [Boolean] - did a leap day (Feb. 29) occur on or between the two dates?
  #   Assume that first_date <= later_date
  #   returns true if either date is a leap day
  def self.leap_day_btwn?(first_date, later_date)
    recent_leap_day = recent_leap_day(later_date)
    first_date <= recent_leap_day && recent_leap_day <= later_date
  end

  # @return [Date] - the most recent leap date (Feb. 29) that is older than date
  def self.recent_leap_day(date = Date.current)
    if date.leap?
      recent_leapyear = date.year
    else
      # not a leap year, so must be 1 of the 3 previous years.
      # (This is a brute force method of checking.)
      given_year = date.year
      prev_years = [date.change(year: given_year - 1),
                    date.change(year: given_year - 2),
                    date.change(year: given_year - 3)]
      recent_leapyear = prev_years.find(&:leap?).year
    end
    Date.new(recent_leapyear, 2, 29)
  end
end
