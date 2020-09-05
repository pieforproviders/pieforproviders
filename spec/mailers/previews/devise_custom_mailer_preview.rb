# frozen_string_literal: true

class DeviseCustomMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    DeviseCustomMailer.confirmation_instructions(User.first, 'token', {})
  end

  def reset_password_instructions
    DeviseCustomMailer.reset_password_instructions(User.first, 'token', {})
  end
end
