# frozen_string_literal: true

# Authorization policies for notifications
class NotificationPolicy < ApplicationPolicy
	class Scope < ApplicationScope
		def resolve
			if user.admin?
				scope.all
			else
				scope.joins(:child).where(children: { businesses: { user: user }})
			end
		end
	end
end