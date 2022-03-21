# frozen_string_literal: true

task prep: :environment do
  unless Rails.env.production?
    exec "yarn lint:fix && \
    yarn test-once && \
    bundle exec rubocop -a && \
    bundle exec rspec && \
    bundle exec rails db:migrate && \
    yarn cy:ci"
  end
end
