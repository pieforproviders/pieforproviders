# frozen_string_literal: true

task ci: :environment do
  exec 'yarn lint:fix && yarn test-once && bundle exec rubocop -a && bundle exec rspec && yarn cy:ci'
end
