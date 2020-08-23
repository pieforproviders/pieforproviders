# frozen_string_literal: true

# Create Confirmations for Users
class ConfirmationsController < Devise::ConfirmationsController
  def new
    super
  end

  def create
    super
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      bypass_sign_in(resource)
      render json: resource
    else
      render json: resource.errors, status: :forbidden
    end
  end
end
