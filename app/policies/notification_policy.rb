# frozen_string_literal: true

# Authorization policies for notifications
class NotificationPolicy < ApplicationPolicy
  # Scope defining which notifications a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(child: :business).where(children: { businesses: { user: } })
      end
    end
  end
end
