# frozen_string_literal: true

# validates that a parameter is a boolean if it is not nil
class BooleanParamValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    [true, false].include?(value)
  rescue TypeError, ArgumentError => e
    record.errors.add(attribute, e.message)
  end
end
