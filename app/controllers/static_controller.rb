# frozen_string_literal: true

# serves the static pages for React
class StaticController < ApplicationController
  def fallback_index_html
    render file: 'client/public/index.html', layout: false
  end
end
