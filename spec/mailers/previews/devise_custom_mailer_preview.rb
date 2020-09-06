# frozen_string_literal: true

# list these mailer preview links with this URL:
# http://localhost:3001/rails/mailers/devise_custom_mailer

class DeviseCustomMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    DeviseCustomMailer.confirmation_instructions(User.first, 'token', {})
  end

  def reset_password_instructions
    DeviseCustomMailer.reset_password_instructions(User.first, 'token', {})
  end

  def password_change
    DeviseCustomMailer.password_change(User.first)
  end
end
