# frozen_string_literal: true

# Serializer for attendances
class AttendanceBlueprint < Blueprinter::Base
  identifier :id
  field :check_in
  field :check_out
  field :time_in_care
  field :child_approval_id

  view :with_child do
    association :child, blueprint: ChildBlueprint
  end
end
