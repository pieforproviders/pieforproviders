# frozen_string_literal: true

# Base controller methods for API controllers
class ApplicationController < ActionController::API
  around_action :collect_metrics

  def fallback_index_html
    Rails.logger.info "\n\nGot to the fallback\n\n"
    if File.exist?('public/index.html')
      Rails.logger.info "\n\n\n#{File.open('public/index.html').read}\n\n\n"
    end
    render file: 'public/index.html'
  end

  def render_resource(resource)
    if resource.errors.empty?
      render json: resource, status: :created, location: resource
    else
      validation_error(resource)
    end
  end

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: '422',
          title: 'Unprocessable Entity',
          detail: resource.errors,
          code: '100'
        }
      ]
    }, status: :unprocessable_entity
  end

  def collect_metrics
    start = Time.zone.now
    yield
    duration = Time.zone.now - start
    Rails.logger.info "#{controller_name}##{action_name}: #{duration}s"
  end
end
