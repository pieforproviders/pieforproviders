# frozen_string_literal: true

# Create Registrations for Users
class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # TODO: #11:
  # confirmation emails?
  # password reset emails?
  # how do we do this in API only mode and on development
  # Verify (and probably fix) Swagger docs endpoints with Auth

  def create
    build_resource(sign_up_params)

    resource.save
    render_resource(resource)
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :active, :email, :full_name, :greeting_name,
      :id, :language, :mobile, :opt_in_email,
      :opt_in_phone, :opt_in_text, :organization, :password,
      :password_confirmation, :phone, :service_agreement_accepted,
      :slug, :timezone
    )
  end
end
