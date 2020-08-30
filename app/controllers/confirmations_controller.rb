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
      render json: { error: error_message, status: :forbidden }
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

  def error_message
    if email_error(resource).present?
      email_error_handler(email_error)
    elsif token_error(resource).present?
      token_error_handler(token_error)
    else
      'theres a problem with your confirmation token, please contact us (but make it different)'
    end
  end

  def email_error(resource)
    resource.errors.details[:email]
  end

  def token_error(resource)
    resource.errors.details[:confirmation_token]
  end

  def email_error_handler(email_error)
    # TODO: Sentry also
    case email_error.first[:error]
    when :already_confirmed
      'this email has already been confirmed (translation)'
    when :confirmation_period_expired
      'your confirmation period has expired, please request another confirmation email (translation)'
    else
      "there's a problem with your email being confirmed, please contact us"
    end
  end

  def token_error_handler(token_error)
    # TODO: Sentry also
    case token_error.first[:error]
    when :blank
      'please provide a confirmation token (translation)'
    when :invalid
      'your confirmation token is invalid, please request another confirmation email (translation)'
    else
      "there's a problem with your confirmation token, please contact us"
    end
  end
end
