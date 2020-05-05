# frozen_string_literal: true

# renders the single static fallback file we need to serve routes correctly from React Router
# rubocop:disable Rails/ApplicationController
class StaticController < ActionController::Base
  def fallback_index_html
    render file: 'public/index.html'
  end
end
# rubocop:enable Rails/ApplicationController
