# frozen_string_literal: true

# Base controller methods for API controllers
class ApplicationController < ActionController::API
  around_action :collect_metrics

  def render_resource(resource)
    if resource.errors.empty?
      render json: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: '400',
          title: 'Bad Request',
          detail: resource.errors,
          code: '100'
        }
      ]
    }, status: :bad_request
  end

  def collect_metrics
    start = Time.zone.now
    yield
    duration = Time.zone.now - start
    Rails.logger.info "#{controller_name}##{action_name}: #{duration}s"
  end
end
