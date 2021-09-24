# frozen_string_literal: true

# Mailer Overrides for Devise default emails
class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  layout 'mailer'

  def confirmation_instructions(record, token, opts = {})
    @greeting_name = record.greeting_name
    @confirmation_path = confirmation_path(token)
    @reply_subject = 'Pie for Providers: question after signup'
    @sender = Devise.mailer_sender
    opts[:subject] = I18n.t('mailers.confirmation_instructions.subject')
    attachments.inline['pielogo.png'] = pie_logo
    super
  end

  def reset_password_instructions(record, token, opts = {})
    @greeting_name = record.greeting_name
    @password_update_path = password_update_path(token)

    opts[:subject] = I18n.t('mailers.reset_password_instructions.subject')
    attachments.inline['pielogo.png'] = pie_logo
    super
  end

  def password_change(record, opts = {})
    @greeting_name = record.greeting_name

    opts[:subject] = I18n.t('mailers.password_change.subject')
    attachments.inline['pielogo.png'] = pie_logo
    super
  end

  private

  def confirmation_path(token)
    "#{domain}/confirm?confirmation_token=#{token}"
  end

  def pie_logo
    File.read(Rails.root.join('app/views/devise/mailer/assets/pielogo.png'))
  end

  def password_update_path(token)
    "#{domain}/password/update?reset_password_token=#{token}"
  end

  def domain
    options = ActionMailer::Base.default_url_options
    protocol = options[:protocol] ? "#{options[:protocol]}://" : ''
    "#{protocol}#{options[:host]}#{options[:port]}"
  end
end
