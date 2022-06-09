# frozen_string_literal: true

# Serializer for notifications
class NotificationBlueprint < Blueprinter::Base
  # association :child do |_child|
  #  blueprint: ChildBlueprint, view: :notification
  # end
  field :first_name do |notification|
    notification.child.first_name
  end
  field :last_name do |notification|
    notification.child.last_name
  end
  field :expires_on do |notification|
    notification.approval.expires_on
  end
  field :effective_on do |notification|
    notification.approval.effective_on
  end
end
