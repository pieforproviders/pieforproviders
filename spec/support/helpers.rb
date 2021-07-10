# frozen_string_literal: true

module Helpers
  def next_weekday(date, weekday)
    date + ((date.wday + weekday + 1) % 7)
  end

  def prior_weekday(date, weekday)
    date - ((date.wday - weekday) % 7)
  end
end
