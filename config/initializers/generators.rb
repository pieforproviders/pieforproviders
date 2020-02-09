# frozen_string_literal: true

# config/initializers/generators.rb

Rails.application.config.generators do |generator|
  generator.orm :active_record, primary_key_type: :uuid
  generator.orm :active_record, foreign_key_type: :uuid
end
