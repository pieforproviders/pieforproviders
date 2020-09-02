# frozen_string_literal: true

# Mailer Overrides for Devise default emails
class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts = {})
    @greeting_name = record.greeting_name
    @token = token
    opts[:subject] = 'Pie for Providers email verification'
    attachments.inline['pieFullTanLogo.svg'] = File.read(Rails.root.join('app/views/devise/mailer/assets/pieFullTanLogo.svg'))
    super
  end
end
