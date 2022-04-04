# frozen_string_literal: true

module Api
  module V1
    # API for user service_days
    class ServiceDaysController < Api::V1::ApiController
      # GET /service_days
      def index
        @service_days = policy_scope(
          ServiceDay.joins(:attendances).includes(child: { business: :user })
          .includes(attendances: { child_approval: :child }).order('children.last_name')
        ).for_week(filter_date)

        render json: ServiceDayBlueprint.render(@service_days)
      end

      private

      def filter_date
        params[:filter_date] ? Time.zone.parse(params[:filter_date]) : Time.current
      end
    end
  end
end
