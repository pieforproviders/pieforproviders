# frozen_string_literal: true

# Serializer for businesses
class BusinessBlueprint < Blueprinter::Base
  identifier :id

  view :dashboard do
    field :name
    exclude :id
  end
end
