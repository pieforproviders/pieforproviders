# frozen_string_literal: true

# Constrain all API requests to the proper version header
class ApiConstraint
  attr_reader :version

  def initialize(options)
    @version = options.fetch(:version)
  end

  # TODO: fix this, maybe with a root controller before_action
  # this just returns "route not found"
  # when the header is missing, which is not true nor helpful

  # all requests from the frontend must have this accept header
  # "Accept: application/vnd.pieforproviders.v1+json"
  def matches?(request)
    request.headers.fetch(:accept).include?("application/vnd.pieforproviders.v#{version}+json")
  end
end
