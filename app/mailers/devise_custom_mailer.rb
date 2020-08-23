# frozen_string_literal: true

class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts = {})
    @greeting_name = record.greeting_name || ''
    opts[:subject] = 'Pie for Providers email verification'
    attachments.inline['pieFullTanLogo.svg'] = File.read("#{Rails.root}/app/views/devise/mailer/assets/pieFullTanLogo.svg")
    super
  end
end
