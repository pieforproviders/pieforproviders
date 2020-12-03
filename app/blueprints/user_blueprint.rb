# frozen_string_literal: true

# Serializer for users
class UserBlueprint < Blueprinter::Base
  identifier :id
  field :greeting_name
  field :language
  field :state do |user|
    user.state
  end
end
