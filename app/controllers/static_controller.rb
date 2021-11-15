# frozen_string_literal: true

# renders the single static fallback file we need to serve routes correctly from React Router
# our application controller is explicitly API-only so we need rubocop to ignore this
# rubocop:disable Rails/ApplicationController
class StaticController < ActionController::Base
  def api_docs
    format = params.fetch(:format, 'html')
    version = params.fetch(:version, 'v1')

    api_docs_path = Rails.root.join("public/api_docs/#{version}/index.#{format}")

    raise ActionController::RoutingError.new(api_docs_path) unless File.exist?(api_docs_path)

    render file: api_docs_path
  end

  def fallback_index_html
    render file: 'public/index.html'
  end
end
# rubocop:enable Rails/ApplicationController
