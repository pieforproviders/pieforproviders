# frozen_string_literal: true

# serves the static pages for React
class StaticController < ApplicationController
  def fallback_index_html
    render file: 'public/index.html', layout: false
  end

  def show_login
    render file: 'public/Login.js'
  end
end
