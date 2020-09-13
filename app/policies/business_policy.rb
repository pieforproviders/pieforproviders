# frozen_string_literal: true

# Authorization policies for businesses
class BusinessPolicy < ApplicationPolicy
  # Scope defining which businesses a user has access to
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user).active
      end
    end
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  private

  def manage?
    admin? || owner?
  end

  def owner?
    record.user == user
  end
end
