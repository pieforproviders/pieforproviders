# frozen_string_literal: true

# Serializer for attendances
class AttendanceBlueprint < Blueprinter::Base
  identifier :id
  field :absence
  field :check_in
  field :check_out
  field :time_in_care
  field :child_approval_id
  association :child, blueprint: ChildBlueprint
end
