# frozen_string_literal: true

# Serializer for attendances
class AttendanceBlueprint < Blueprinter::Base
  identifier :id
  field :absence
  field :check_in
  field :check_out
  field :time_in_care do |attendance|
    attendance.time_in_care.to_s
  end
  field :child_approval_id
  field :wonderschool_id
  association :child, blueprint: ChildBlueprint
end
