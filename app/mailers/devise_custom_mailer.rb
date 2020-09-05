# frozen_string_literal: true

# Mailer Overrides for Devise default emails
class DeviseCustomMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def confirmation_instructions(record, token, opts = {})
    @greeting_name = record.greeting_name
    @token = token
    @confirmation_path = confirmation_path
    opts[:subject] = I18n.t('mailers.confirmation_instructions.subject')
    @reply_subject = 'Pie for Providers: question after signup'
    @body = I18n.t('mailers.confirmation_instructions.body')
    @hello = I18n.t('mailers.confirmation_instructions.hello')
    @confirm_account = I18n.t('mailers.confirmation_instructions.confirm_account')
    @questions = I18n.t('mailers.confirmation_instructions.questions')
    @sender = Devise.mailer_sender
    attachments.inline['pielogo.png'] = File.read(Rails.root.join('app/views/devise/mailer/assets/pielogo.png'))
    super
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def confirmation_path
    options = ActionMailer::Base.default_url_options
    protocol = options[:protocol] ? "#{options[:protocol]}://" : ''
    "#{protocol}#{options[:host]}#{options[:port]}/confirm?confirmation_token=#{@token}"
  end
end
