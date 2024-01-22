# frozen_string_literal: true

# Authorization policies for children
class ChildPolicy < ApplicationPolicy
  # Scope defining which children a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(child_businesses: :business).where(businesses: { user_id: user.id })
      end
    end
  end
end
