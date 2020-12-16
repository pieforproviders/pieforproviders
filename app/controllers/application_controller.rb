# frozen_string_literal: true

# Base controller methods for API controllers
class ApplicationController < ActionController::API
  before_action :set_raven_context
  before_action :set_locale
  around_action :collect_metrics

  def render_resource(resource)
    if resource.errors.empty?
      render json: resource, status: :created, location: resource
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

  # from https://www.kostolansky.sk/posts/localize-rails-enums/
  def t_enum(enum_name, enum_value)
    enum_i18n_key = enum_name.to_s.pluralize
    I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_i18n_key}.#{enum_value}")
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
    Rails.logger.info "#{controller_name}##{action_name}: #{duration}s"
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
