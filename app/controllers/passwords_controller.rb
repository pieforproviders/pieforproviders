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

  private

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
