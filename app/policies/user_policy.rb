# frozen_string_literal: true

# Authorization policies for users
class UserPolicy < ApplicationPolicy
  # Scope defining which users a user has access to
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id).active
      end
    end
  end

  def index?
    admin?
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
    user == record
  end
end
