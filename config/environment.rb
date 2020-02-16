# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.configure do
  config.action_mailer.default_url_options = { host: ENV.fetch('BINDING', 'localhost'), port: ENV.fetch('PORT', 3000) }
end
