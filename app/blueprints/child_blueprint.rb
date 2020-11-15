# frozen_string_literal: true

# Serializer for children
class ChildBlueprint < Blueprinter::Base
  identifier :id

  view :dashboard do
    field :full_name
    association :business, blueprint: BusinessBlueprint, view: :dashboard
    association :approvals, blueprint: ApprovalBlueprint, view: :dashboard do |child|
      child.approvals.current
    end
    exclude :id
  end
end
