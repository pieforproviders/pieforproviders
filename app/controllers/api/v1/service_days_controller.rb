# frozen_string_literal: true

module Api
  module V1
    # API for user service_days
    class ServiceDaysController < Api::V1::ApiController
      # GET /service_days
      def index
        @service_days = policy_scope(
          ServiceDay.left_outer_joins(:attendances).includes(child: { business: :user })
          .includes(attendances: { child_approval: :child }).order('children.last_name')
        ).for_week(filter_date)

        render json: ServiceDayBlueprint.render(@service_days)
      end

      # POST /service_days
      def create
        @service_day = ServiceDay.new(
          child_id: service_day_params[:child_id],
          date: date,
          absence_type: service_day_params[:absence_type]
        )

        if @service_day.save
          render json: @service_day, status: :created
        else
          render json: @service_day.errors, status: :unprocessable_entity
        end
      end

      private

      def date
        service_day_params[:date]
          .to_date
          .in_time_zone(Child.find_by(id: service_day_params[:child_id])&.timezone)
      end

      def filter_date
        params[:filter_date] ? Time.zone.parse(params[:filter_date]) : Time.current
      end

      def service_day_params
        params.require(:service_day).permit(:date, :absence_type, :child_id)
      end
    end
  end
end
