# frozen_string_literal: true

# Mailer Overrides for Devise default emails
class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  layout 'mailer'

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def confirmation_instructions(record, token, opts = {})
    @greeting_name = record.greeting_name
    @token = token
    @confirmation_path = confirmation_path
    opts[:subject] = I18n.t('mailers.confirmation_instructions.subject')
    @reply_subject = 'Pie for Providers: question after signup'
    @body = I18n.t('mailers.confirmation_instructions.body')
    @hello = I18n.t('hello')
    @questions = I18n.t('mailers.confirmation_instructions.questions')
    @sender = Devise.mailer_sender
    attachments.inline['pielogo.png'] = File.read(Rails.root.join('app/views/devise/mailer/assets/pielogo.png'))
    super
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def reset_password_instructions(record, token, opts = {})
    @token = token
    @greeting_name = record.greeting_name
    @password_update_path = password_update_path

    opts[:subject] = I18n.t('mailers.reset_password_instructions.subject')
    attachments.inline['pielogo.png'] = File.read(Rails.root.join('app/views/devise/mailer/assets/pielogo.png'))
    super
  end

  def password_change(record, opts = {})
    @greeting_name = record.greeting_name

    opts[:subject] = I18n.t('mailers.password_change.subject')
    attachments.inline['pielogo.png'] = File.read(Rails.root.join('app/views/devise/mailer/assets/pielogo.png'))
    super
  end

  private

  def confirmation_path
    "#{domain}/confirm?confirmation_token=#{@token}"
  end

  def password_update_path
    "#{domain}/password/update?reset_password_token=#{@token}"
  end

  def domain
    options = ActionMailer::Base.default_url_options
    protocol = options[:protocol] ? "#{options[:protocol]}://" : ''
    "#{protocol}#{options[:host]}#{options[:port]}"
  end
end
