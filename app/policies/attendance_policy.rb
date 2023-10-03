# frozen_string_literal: true

# Authorization policies for attendances
class AttendancePolicy < ApplicationPolicy
  # Scope defining which attendances a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(child_approval: {
                      child: { child_businesses: :business }
                    })
             .where(child_approvals: {
                      child: {
                        child_businesses: {
                          currently_active: true,
                          businesses: {
                            user: user,
                            active: true
                          }
                        }
                      }
                    })
      end
    end
  end
end
