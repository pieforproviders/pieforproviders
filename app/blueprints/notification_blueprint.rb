# frozen_string_literal: true

# Serializer for notifications
class NotificationsBlueprint < Blueprinter::Base
	association :child, blueprint: ChildBlueprint, view: :notification
	assocaition :approval, blueprint: NotificationsBlueprint, view: :notification
end