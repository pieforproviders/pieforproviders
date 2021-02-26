# frozen_string_literal: true

# validates that a parameter is in date format, or converts it
class DateParamValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.is_a?(Date) ? value : Date.parse(value)
  rescue TypeError, ArgumentError => e
    record.errors.add(attribute, e)
  end
end
