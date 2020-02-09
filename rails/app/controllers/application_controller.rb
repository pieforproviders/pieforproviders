# frozen_string_literal: true

# Base controller methods for API controllers
class ApplicationController < ActionController::API
  around_action :collect_metrics

  def collect_metrics
    start = Time.zone.now
    yield
    duration = Time.zone.now - start
    Rails.logger.info "#{controller_name}##{action_name}: #{duration}s"
  end
end
