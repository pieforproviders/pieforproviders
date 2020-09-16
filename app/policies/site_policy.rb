# frozen_string_literal: true

# Authorization policies for sites
class SitePolicy < ApplicationPolicy
  # Scope defining which sites a user has access to
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:business).where(businesses: { user: user }).active
      end
    end
  end

  def create?
    # To check if the record has a business associated to
    # the user, we need to make sure `record.business` is not nil.
    # i.e. the record has to be valid.
    # We return true if the record is invalid as it will fail anyway.
    if record.valid?
      admin_or_owner?
    else
      true
    end
  end
end
