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
      render json: { error: error_message(resource) }, status: :forbidden
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

  def error_message(resource)
    if email_error(resource).present?
      email_error_handler(email_error(resource))
    elsif token_error(resource).present?
      token_error_handler(token_error(resource))
    else
      I18n.t('errors.messages.generic_confirmation_error')
    end
  end

  def email_error(resource)
    resource.errors.details[:email]
  end

  def token_error(resource)
    resource.errors.details[:confirmation_token]
  end

  def email_error_handler(email_error)
    case email_error.first[:error]
    when :already_confirmed
      I18n.t('errors.messages.already_confirmed')
    when :confirmation_period_expired
      I18n.t('errors.messages.confirmation_period_expired')
    else
      I18n.t('errors.messages.generic_email_confirmation_error')
    end
  end

  def token_error_handler(token_error)
    case token_error.first[:error]
    when :blank
      I18n.t('errors.messages.confirmation_token_blank')
    when :invalid
      I18n.t('errors.messages.confirmation_token_invalid')
    else
      I18n.t('errors.messages.generic_confirmation_error')
    end
  end
end
