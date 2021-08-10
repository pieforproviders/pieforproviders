# frozen_string_literal: true

# Authorization policies for child approvals
class ChildApprovalPolicy < ApplicationPolicy
  # Scope defining which child approvals a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:business).where(businesses: { user: user })
      end
    end
  end
end
