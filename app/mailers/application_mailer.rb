# frozen_string_literal: true

# Action Mailer allows you to send emails from your application using mailer classes and views.
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SENDMAIL_USERNAME', '')
  layout 'mailer'
end
