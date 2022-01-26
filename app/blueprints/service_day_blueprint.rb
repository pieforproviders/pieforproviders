# frozen_string_literal: true

# Serializer for service_days
class ServiceDayBlueprint < Blueprinter::Base
  identifier :id
  field :child_id
  field :date
  field :tags
  field :total_time_in_care
  association :attendances, blueprint: AttendanceBlueprint
end
