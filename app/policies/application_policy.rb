# frozen_string_literal: true

# Base policy class
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    @user = user
    @record = record
  end

  def index?
    true
  end

  def create?
    true
  end

  def update?
    admin_or_owner?
  end

  def destroy?
    admin_or_owner?
  end

  # Base policy scope class
  class Scope
    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user

      @user  = user
      @scope = scope
    end

    private

    attr_reader :user, :scope
  end

  protected

  def admin_or_owner?
    admin? || owner?
  end

  def owner?
    record.user == user
  end

  def admin?
    user.admin?
  end
end
