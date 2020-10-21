# frozen_string_literal: true

# Authorization policies for billable occurrences
class BillableOccurrencePolicy < ApplicationPolicy
  # Scope defining which billable occurrences a user has access to
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(child_approval: { child: { business: :user } }).where(child_approvals: { children: { businesses: { user: user } } })
      end
    end
  end
end
