# frozen_string_literal: true

# validates that a parameter is in datetime format, or converts it
class DateTimeParamValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.is_a?(DateTime) ? value : DateTime.parse(value.to_s).to_datetime
  rescue TypeError, ArgumentError => e
    record.errors.add(attribute, e.message)
  end
end
