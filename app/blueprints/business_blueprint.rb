# frozen_string_literal: true

# Serializer for businesses
class BusinessBlueprint < Blueprinter::Base
  identifier :id

  view :illinois_dashboard do
    field :name
    exclude :id
    association :children, name: :cases, blueprint: ChildBlueprint, view: :illinois_dashboard do |business, options|
      business.children.active.approved_for_date(options[:from_date])
    end
  end

  view :nebraska_dashboard do
    field :name
    exclude :id
    association :children, name: :cases, blueprint: ChildBlueprint, view: :nebraska_dashboard do |business, options|
      business.children.active.approved_for_date(options[:from_date])
    end
  end
end
