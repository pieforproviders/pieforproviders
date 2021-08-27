# frozen_string_literal: true

# Serializer for attendances
class AttendanceBlueprint < Blueprinter::Base
  identifier :id
  field :absence
  field :check_in
  field :check_out
  field :total_time_in_care do |attendance|
    attendance.total_time_in_care.to_s
  end
  field :child_approval_id
  association :child, blueprint: ChildBlueprint
end
