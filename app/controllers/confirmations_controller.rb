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
      sign_in(resource)
      response.headers['authorization'] = current_token
      render json: resource
    else
      # TODO: Concatenate "email has already been confirmed"
      # errorMessage: { error: { email: ["was already confirmed, please try signing in"] } }
      render json: { error: resource.errors }, status: :forbidden
    end
  end

  private

  def current_token
    request.env['warden-jwt_auth.token']
  end
end
