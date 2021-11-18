# frozen_string_literal: true

# Authorization policies for service_days
class ServiceDayPolicy < ApplicationPolicy
  # Scope defining which service_days a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(child: {
                      business: :user
                    }).where(children: { businesses: { user: user } })
      end
    end
  end
end
