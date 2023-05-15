# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
# require 'rails/test_unit/railtie'
require './lib/log/console_logger'
require './lib/log/console_formatter'
require './lib/log/file_logger'
require './lib/log/file_formatter'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  # The Application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.autoload_paths << Rails.root.join('lib').to_s

    config.active_record.schema_format = :ruby

    config.time_zone = 'UTC'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    logger_file = ActiveSupport::TaggedLogging.new(Log::FileLogger.new("log/#{Rails.env}.log"))
    logger_console = ActiveSupport::TaggedLogging.new(Log::ConsoleLogger.new($stdout))
    config.logger = logger_file
    if ENV['RAILS_LOG_TO_STDOUT'] == 'true' && defined?(Rake) && !Rails.env.test?
      config.logger.extend(ActiveSupport::Logger.broadcast(logger_console))
    end

    config.i18n.available_locales = %i[en es]
    config.i18n.default_locale = :en

    config.active_job.queue_adapter = :good_job

    # custom configuration
    config.allow_seeding = ENV.fetch('ALLOW_SEEDING', false) == 'true'
    config.sendmail_username = ENV.fetch('SENDMAIL_USERNAME', '')

    # performance testing
    config.performance_testing = ENV.fetch('PERFORMANCE_TESTING', false) == 'true'

    # AWS
    config.aws_access_key_id = ENV.fetch('AWS_ACCESS_KEY_ID', '')
    config.aws_secret_access_key = ENV.fetch('AWS_SECRET_ACCESS_KEY', '')
    config.aws_region = ENV.fetch('AWS_REGION', '')

    # onboarding
    config.aws_onboarding_bucket = ENV.fetch('AWS_ONBOARDING_BUCKET', '')
    config.aws_onboarding_archive_bucket = ENV.fetch('AWS_ONBOARDING_ARCHIVE_BUCKET', '')

    # Wonderschool Attendance - NECC
    config.wonderschool_attendance_url = ENV.fetch('WONDERSCHOOL_ATTENDANCE_URL', '')

    # self-serve attendance
    config.aws_necc_attendance_bucket = ENV.fetch('AWS_NECC_ATTENDANCE_BUCKET', '')
    config.aws_necc_attendance_archive_bucket = ENV.fetch('AWS_NECC_ATTENDANCE_ARCHIVE_BUCKET', '')

    config.middleware.use Rack::RubyProf, path: './tmp/profile' if Rails.env.profile?
    config.middleware.use(Rack::ContentLength)
  end
end
