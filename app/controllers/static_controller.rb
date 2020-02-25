# frozen_string_literal: true

# serves the static pages for React
class StaticController < ActionController::Base
  def fallback_index_html
    render file: 'public/index.html', layout: false
  end
end
