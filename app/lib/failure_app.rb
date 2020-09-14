# frozen_string_literal: true

# Custom failure app to handle warden errors
class FailureApp < Devise::FailureApp
  def http_auth_body
    {
      attribute: 'email',
      error: i18n_message,
      type: warden_message || 'unauthenticated'
    }.to_json
  end
end
