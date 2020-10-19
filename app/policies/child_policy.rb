# frozen_string_literal: true

# Authorization policies for children
class ChildPolicy < ApplicationPolicy
  # Scope defining which children a user has access to
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:business).where(businesses: { user: user })
      end
    end
  end
end
