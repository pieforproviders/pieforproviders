# frozen_string_literal: true

# Base policy class
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
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
    admin?
  end

  def destroy?
    admin?
  end

  # Base policy scope class
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    private

    attr_reader :user, :scope
  end

  private

  def admin?
    user.admin?
  end
end
