# frozen_string_literal: true

# Authorization policies for users
class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def create?
    true
  end

  # Scope defining which users a user has access to
  class Scope < ApplicationScope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id).active
      end
    end
  end

  private

  def owner?
    user == record
  end
end
