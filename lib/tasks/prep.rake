# frozen_string_literal: true

task prep: :environment do
  # the db:migrate in the middle of this prep is what runs the erd generation and annotation update; migrate:with_data will not do it
  exec "yarn lint:fix &&
        yarn test-once &&
        bundle exec rails erd annotate_models annotate_routes &&
        bundle exec rubocop -a &&
        bundle exec rspec &&
        COVERAGE=false bundle exec rails rswag &&
        yarn cy:ci"
end
