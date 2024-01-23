# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'appsignal'
gem 'aws-sdk-s3', '~> 1'
gem 'blueprinter', '~> 1.0.1'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'daru'
gem 'data_migrate'
gem 'devise'
gem 'devise-jwt'
gem 'faker'
gem 'good_job'
gem 'hash_dig_and_collect'
gem 'holidays'
gem 'matrix'
gem 'money-rails'
gem 'net-pop'
gem 'net-smtp'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 6.4'
gem 'pundit', '~> 2.3'
gem 'rails', '~> 7.0.8'
gem 'redis'
gem 'reverse_markdown'
gem 'roo', '~> 2.7', '>= 2.7.1'
gem 'skylight'
gem 'tod'

gem 'flamegraph'
gem 'memory_profiler'
gem 'pdf-reader'
gem 'rack-mini-profiler'
gem 'rainbow'
gem 'stackprof'
gem 'terminal-table'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'brakeman'
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'cypress-on-rails', '~> 1.13'
  gem 'factory_bot_rails' # we use factorybot for seeding so it must be in both groups
  gem 'pry'
  gem 'pry-remote'
  gem 'rspec-benchmark'
  gem 'rspec-rails'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  gem 'annotate', github: 'Vasfed/annotate_models', branch: 'rails6_warning'
  gem 'benchmark-ips'
  gem 'guard-rspec', require: false
  gem 'letter_opener_web', '~> 2.0'
  gem 'listen', '>= 3.0.5', '< 3.8'
  gem 'pgreset', '~> 0.3'
  gem 'rails-erd'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
end

group :test do
  gem 'database_cleaner'
  gem 'json-schema'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

group :profile do
  gem 'ruby-prof'
end

group :development, :test, :profile do
  gem 'dotenv-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
