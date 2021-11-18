# frozen_string_literal: true

# Serializer for service_days
class ServiceDayBlueprint < Blueprinter::Base
  identifier :id
  field :child_id
  field :date
  field :tags
  # rubocop:disable Style/SymbolProc
  field :total_time_in_care do |service_day|
    service_day.total_time_in_care
  end
  # rubocop:enable Style/SymbolProc
  association :attendances, blueprint: AttendanceBlueprint
end
