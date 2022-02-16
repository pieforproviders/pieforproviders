# frozen_string_literal: true

# validates that a parameter is in time format, or converts it
class TimeParamValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.is_a?(Time) ? value : Time.zone.parse(value)
  rescue TypeError, ArgumentError => e
    send_appsignal_error('time-param-invalid', e, [record&.id, record&.class].join(', '))
    record.errors.add(attribute, e.message)
  end
end
