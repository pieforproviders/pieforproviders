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
    field :attendance_risk do |child|
      child.attendance_risk
    end
    field :attendance_rate do |child|
      child.attendance_rate
    end
    field :guaranteed_revenue do |child|
      child.guaranteed_revenue
    end
    field :potential_revenue do |child|
      child.potential_revenue
    end
    field :max_approved_revenue do |child|
      child.max_approved_revenue
    end
    exclude :id
  end
end
