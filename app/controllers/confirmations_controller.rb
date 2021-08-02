# frozen_string_literal: true

# TODO: Make sure the front end isn't using the response from confirmations to do anything
# TODO: ensure the front end sends confirmation, password and signup information nested under user:

# Create Confirmations for Users
class ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    if successfully_sent?(resource)
      render json: { success: true }
    else
      errors(resource.errors.details)
      render json: error_response, status: :unprocessable_entity
    end
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    if resource.errors.empty?
      sign_in_resource(resource)
    else
      errors(resource.errors.details)
      render json: error_response, status: :forbidden
    end
  end

  private

  def errors(details = nil)
    @errors ||= details
  end

  def error_response
    {
      error: I18n.t('errors.messages.confirmation'),
      attribute: error_attribute.to_s,
      type: error_type.to_s
    }
  end

  def sign_in_resource(resource)
    return unless resource.confirmed?

    sign_in(resource)
    response.headers['authorization'] = current_token
    render json: UserBlueprint.render(resource)
  end

  def current_token
    request.env['warden-jwt_auth.token']
  end

  def error_attribute
    @error_attribute ||= @errors.keys.first
  end

  def error_type
    @error_type ||= @errors[@error_attribute].first[:error]
  end
end
