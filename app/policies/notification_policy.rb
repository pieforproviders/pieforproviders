# frozen_string_literal: true

# Authorization policies for notifications
class NotificationPolicy < ApplicationPolicy
  # Scope defining which notifications a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(child: { child_businesses: :business })
             .where('child_businesses.currently_active = ? AND businesses.user_id = ?', true, user.id)
      end
    end
  end
end
