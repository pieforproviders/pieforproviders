# frozen_string_literal: true

# Authorization policies for businesses
class BusinessPolicy < ApplicationPolicy
  # Scope defining which businesses a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user:).active
      end
    end
  end
end
