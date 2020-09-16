# frozen_string_literal: true

# Authorization policies for case cycles
class CaseCyclePolicy < ApplicationPolicy
  # Scope defining which case cycles a user has access to
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
