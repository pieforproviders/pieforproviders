# frozen_string_literal: true

# Serializer for payments
class PaymentBlueprint < Blueprinter::Base
  identifier :id
  field :month
  field :amount
  field :child_approval_id
end
