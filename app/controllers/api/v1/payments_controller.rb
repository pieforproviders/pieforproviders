# frozen_string_literal: true

module Api
  module V1
    # API for user payments
    class PaymentsController < Api::V1::ApiController
      # GET /payments
      def index
        @payments = policy_scope(Payment).for_month(filter_date)

        render json: PaymentBlueprint.render(@payments)
      end

      def filter_date
        return Time.zone.parse(params[:filter_date]) if params[:filter_date]
        Time.zone.today
      end
    end
  end
end
