# frozen_string_literal: true

module Helpers
  def next_weekday(date, weekday)
    date.next_occurring(Date::DAYNAMES[weekday].downcase.to_sym)
  end

  def prior_weekday(date, weekday)
    date.prev_occurring(Date::DAYNAMES[weekday].downcase.to_sym)
  end

  def last_elapsed_date(date)
    if Date.parse(date).month > Time.current.month
      Date.parse("#{date}, #{Time.current.year - 1}")
    else
      Date.parse("#{date}, #{Time.current.year}")
    end
  end
end
