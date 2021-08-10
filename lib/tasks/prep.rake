# frozen_string_literal: true

task prep: :environment do
  unless Rails.env.production?
    exec "yarn lint:fix && \
    yarn test-once && \
    bundle exec rubocop -a && \
    bundle exec rspec && \
    bundle exec rails db:migrate:with_data && \
    yarn cy:ci"
  end
end
