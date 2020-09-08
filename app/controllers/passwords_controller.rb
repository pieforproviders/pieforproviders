# frozen_string_literal: true

# Allows users to reset passwords
class PasswordsController < Devise::PasswordsController
  respond_to :json

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(resource)
      render json: { success: true }
    else
      render json: error_response, status: :unprocessable_entity
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      sign_in_resource
      render json: resource
    else
      render json: error_response, status: :unprocessable_entity
    end
  end

  private

  def sign_in_resource
    return unless resource.confirmed?

    sign_in(resource)
    response.headers['authorization'] = current_token
  end

  def current_token
    request.env['warden-jwt_auth.token']
  end

  def error_response
    @errors = resource.errors.details

    {
      attribute: error_attribute.to_s,
      type: error_type.to_s
    }
  end

  def error_attribute
    @errors.keys.first
  end

  def error_type
    @errors[error_attribute].first[:error]
  end

  def resource_params
    params.fetch(:user, {})
  end
end
