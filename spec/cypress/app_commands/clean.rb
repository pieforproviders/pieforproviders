# frozen_string_literal: true

# cleaning the database using database_cleaner
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean
Rails.logger.info 'APPCLEANED' # used by log_fail.rb
