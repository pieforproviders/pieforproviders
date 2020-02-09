# frozen_string_literal: true

# Constrain all API requests to the proper version header
class ApiConstraint
  attr_reader :version

  def initialize(options)
    @version = options.fetch(:version)
  end

  # all requests from the frontend must have this accept header
  # "Accept: application/vnd.pieforproviders.v1+json"
  def matches?(request)
    request.headers.fetch(:accept).include?("application/vnd.pieforproviders.v#{version}+json")
  end
end
