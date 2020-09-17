# frozen_string_literal: true

# validates that a parameter is in date format, or converts it
class DateParamValidator < ActiveModel::EachValidator
  INVALID_DATE_MSG = 'Invalid date'

  def self.invalid_date_msg
    INVALID_DATE_MSG
  end

  def validate_each(record, attribute, value)
    value&.is_a?(Date) ? value : Date.parse(value)
  rescue TypeError, ArgumentError
    record.errors.add(attribute, self.class.invalid_date_msg)
  end
end
