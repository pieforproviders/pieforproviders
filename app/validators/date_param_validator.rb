# frozen_string_literal: true

# validates that a parameter is in date format, or converts it
class DateParamValidator < ActiveModel::EachValidator
  include AppsignalReporting

  def validate_each(record, attribute, value)
    value.is_a?(Date) ? value : Time.zone.parse(value).to_date
  rescue TypeError, ArgumentError => e
    send_appsignal_error(
      action: 'date-param-invalid',
      exception: e,
      tags: {
        record_id: record&.id,
        record_class: record&.class
      }
    )
    record.errors.add(attribute, e.message)
  end
end
