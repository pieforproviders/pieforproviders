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
      sign_in_resource(resource)
    else
      render json: { error: resource.errors }, status: :forbidden
    end
  end

  private

  def sign_in_resource(resource)
    sign_in(resource)
    response.headers['authorization'] = current_token
    render json: resource
  end

  def current_token
    request.env['warden-jwt_auth.token']
  end
end
