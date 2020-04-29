# frozen_string_literal: true

# base controller for the V1 API
class Api::V1::ApiController < ApplicationController
  before_action :authenticate_user!
end
