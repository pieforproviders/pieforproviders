# frozen_string_literal: true

# Authorization policies for payments
class PaymentPolicy < ApplicationPolicy
  # Scope defining which payments a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(child_approval: {
                      child: { business: :user }
                    }).where(child_approvals: { children: { businesses: { user: user } } })
      end
    end
  end
end
