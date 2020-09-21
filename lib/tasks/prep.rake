# frozen_string_literal: true

task prep: :environment do
  exec 'yarn --cwd client lint:fix && yarn test-once && bundle exec rubocop -a && bundle exec rspec && COVERAGE=false bundle exec rails rswag && yarn cy:ci'
end
