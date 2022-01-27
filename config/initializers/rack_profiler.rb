# frozen_string_literal: true

# if Rails.env.development?
#   require 'rack-mini-profiler'

#   # initialization is skipped so trigger it
#   Rack::MiniProfilerRails.initialize!(Rails.application)
# end

Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore

# set RedisStore
if Rails.env.production?
  Rack::MiniProfiler.config.storage_options = { url: ENV['REDIS_URL'] }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
end

Rack::MiniProfiler.config.user_provider = proc { |env| CurrentUser.get(env) }
