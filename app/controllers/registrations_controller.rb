# frozen_string_literal: true

# Create Registrations for Users
class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # TODO: #11:
  # password reset emails?
  # Verify (and probably fix) Swagger docs endpoints with Auth
  # Design Emails for Confirmation and Reset that will send the user to /login after hitting the API with the token in the email they're being sent

  def create
    build_resource(sign_up_params)

    resource.save
    render_resource(resource)
  end

  private

  # rubocop:disable Metrics/MethodLength
  def sign_up_params
    params.require(:user).permit(:active,
                                 :email,
                                 :full_name,
                                 :greeting_name,
                                 :language,
                                 :opt_in_email,
                                 :opt_in_text,
                                 :organization,
                                 :password,
                                 :password_confirmation,
                                 :phone_number,
                                 :phone_type,
                                 :service_agreement_accepted,
                                 :timezone)
  end
  # rubocop:enable Metrics/MethodLength
end
