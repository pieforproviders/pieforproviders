# frozen_string_literal: true

module Api
  module V1
    # API for user payments
    class PaymentsController < Api::V1::ApiController
      # GET /payments
      def index
        if params[:filter_date]
            @payments = policy_scope(Payment).for_month(filter_date)
        else
            @payments = policy_scope(Payment)
        end

        render json: PaymentBlueprint.render(@payments)
      end

      def filter_date
        Time.zone.parse(params[:filter_date])&.at_end_of_day
      end
    end
  end
end
