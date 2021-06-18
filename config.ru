# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.
begin
  require_relative 'config/environment'

  run Rails.application
rescue StandardError => e
  Appsignal.send_error(e)
  raise
end
