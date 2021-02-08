# frozen_string_literal: true

module Api
  module V1
    # base controller for the V1 API
    class ApiController < ApplicationController
      before_action :authenticate_user!

      include Pundit

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      def user_not_authorized
        head :forbidden
      end

      def not_found
        head :not_found
      end
    end
  end
end
