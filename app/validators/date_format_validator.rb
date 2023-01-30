# frozen_string_literal: true

# validates that the format of a given date is correct
class DateFormatValidator < ActiveModel::EachValidator
  include AppsignalReporting

  def valid_date_format?(date)
    Date.iso8601(date)
    true
  rescue ArgumentError
    false
  end
end