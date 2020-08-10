# frozen_string_literal: true

# validates that a parameter is in date format, or converts it
class DateParamValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    value&.is_a?(Date) ? value : Date.parse(value)
  rescue TypeError, ArgumentError
    record.errors.add(:date_param, 'Invalid date')
  end
end
