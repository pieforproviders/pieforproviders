# frozen_string_literal: true

# Base controller methods for API controllers
class ApplicationController < ActionController::API
  before_action :set_appsignal_context
  before_action :set_locale
  around_action :collect_metrics
  before_action :set_current_user

  before_action do
    if Rails.env.development? || (Rails.env.production? && current_user && current_user.admin? && params[:rmp])
      Rack::MiniProfiler.authorize_request
    end
  end

  def set_current_user
    Thread.current[:current_user] = current_user
  end

  def render_resource(resource)
    if resource.errors.empty?
      render json: UserBlueprint.render(resource), status: :created, location: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
             status: '422',
             title: 'Unprocessable Entity',
             errors: resource.errors.details,
             detail: resource.errors,
             code: '100'
           },
           status: :unprocessable_entity
  end

  private

  def set_appsignal_context
    Appsignal.tag_request(
      user_id: current_user&.id,
      url: request.url,
      params: params.to_unsafe_h.to_s,
      locale: I18n.locale,
      default_locale: I18n.default_locale
    )
  end

  def collect_metrics
    start = Time.current
    yield
    duration = Time.current - start
    Rails.logger.info "DURATION | #{controller_name}##{action_name}: #{duration}s"
  end

  def set_locale
    I18n.locale = locale
  end

  def locale
    LocaleExtractor.new(accept_lang_header).extract
  end

  def accept_lang_header
    request.headers['Accept-Language'].presence || ''
  end
end
