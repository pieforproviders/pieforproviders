# frozen_string_literal: true

# Base controller methods for API controllers
class ApplicationController < ActionController::API
  include Logging
  before_action :set_raven_context
  before_action :set_locale
  around_action :collect_metrics

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
    }, status: :unprocessable_entity
  end

  private

  def set_raven_context
    return unless Rails.env.production?

    Raven.user_context(id: current_user.id) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def collect_metrics
    start = Time.zone.now
    yield
    duration = Time.zone.now - start
    log(:info,"#{controller_name}##{action_name}: #{duration}s")
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
