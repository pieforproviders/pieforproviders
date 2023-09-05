# frozen_string_literal: true

# Authorization policies for service_days
class ServiceDayPolicy < ApplicationPolicy
  # Scope defining which service_days a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all.joins(child: { child_businesses: :business }).where(children: { businesses: { state: user.state } })
      else
        scope.joins(child: { child_businesses: { business: :user } }).where(businesses: { user: })
      end
    end
  end
end
