# frozen_string_literal: true

# Serializer for approvals
class ApprovalBlueprint < Blueprinter::Base
  view :notification do
    fields :effective_on, :expires_on
  end
end
