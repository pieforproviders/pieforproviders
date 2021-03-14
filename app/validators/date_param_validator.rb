# frozen_string_literal: true

# validates that a parameter is in date format, or converts it
class DateParamValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.is_a?(Date) ? value : Time.zone.parse(value).to_date
  rescue TypeError, ArgumentError => e
    record.errors.add(attribute, e.message)
  end
end
