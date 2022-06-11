# frozen_string_literal: true

# validates that a parameter is in time format, or converts it
class TimeParamValidator < ActiveModel::EachValidator
  include AppsignalReporting

  def validate_each(record, attribute, value)
    value.is_a?(Time) ? value : Time.zone.parse(value)
  rescue TypeError, ArgumentError => e
    send_appsignal_error(
      action: 'time-param-invalid',
      exception: e,
      metadata: {
        record_id: record&.id,
        record_class: record&.class
      }
    )
    record.errors.add(attribute, e.message)
  end
end
