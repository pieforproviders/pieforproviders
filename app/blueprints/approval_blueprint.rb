# frozen_string_literal: true

# Serializer for approvals
class ApprovalBlueprint < Blueprinter::Base
  identifier :id

  view :dashboard do
    field :case_number
    exclude :id
  end
end
