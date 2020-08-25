# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'data_migrate'
gem 'devise'
gem 'devise-jwt'
gem 'money-rails'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'rails', '~> 6.0.3.2'
gem 'rswag-api'
gem 'rswag-ui'

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
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails' # we use factorybot for seeding so it must be in both groups
  gem 'faker'
  gem 'pry'
  gem 'pry-remote'
  gem 'rspec-rails'
  gem 'rswag-specs'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
end

group :development do
  gem 'annotate'
  gem 'guard-rspec', require: false
  gem 'letter_opener_web', '~> 1.4'
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'pgreset'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'json-schema'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
