# frozen_string_literal: true

# Authorization policies for child case cycles
class ChildCaseCyclePolicy < ApplicationPolicy
  # Scope defining which child case cycles a user has access to
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:case_cycle).where(case_cycles: { user_id: user.id })
      end
    end
  end

  def create?
    # To check if the record has a child and a case cycle associated to
    # the user, we need to make sure `record.case_cycle` and `record.child`
    # are not nil. i.e. the record has to be valid.
    # We return true if the record is invalid as it will fail anyway.
    if record.valid?
      admin? || (owner? && record.child.user == user)
    else
      true
    end
  end
end
