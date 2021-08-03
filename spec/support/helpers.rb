# frozen_string_literal: true

module Helpers
  def next_weekday(date, weekday)
    date.next_occurring(Date::DAYNAMES[weekday].downcase.to_sym)
  end

  def prior_weekday(date, weekday)
    date.prev_occurring(Date::DAYNAMES[weekday].downcase.to_sym)
  end

  def last_elapsed_date(date)
    Date.parse(date).month > Time.zone.now.month ? Date.parse("#{date}, #{Time.zone.now.year - 1}") : Date.parse("#{date}, #{Time.zone.now.year}")
  end
end
