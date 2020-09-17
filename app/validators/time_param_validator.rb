# frozen_string_literal: true

# validates that a parameter is in time format, or converts it
class TimeParamValidator < ActiveModel::EachValidator
  INVALID_TIME_MSG = 'Invalid time'

  def self.invalid_time_msg
    INVALID_TIME_MSG
  end

  def validate_each(record, attribute, value)
    value&.is_a?(Time) ? value : Time.zone.parse(value)
  rescue TypeError, ArgumentError
    record.errors.add(attribute, self.class.invalid_time_msg)
  end
end
