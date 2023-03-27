# frozen_string_literal: true

module Api
  module V1
    # API for user service_days
    class ServiceDaysController < Api::V1::ApiController
      before_action :set_service_days, only: %i[index]
      before_action :set_service_day, only: %i[update destroy show]

      # GET /service_days
      def index
        render json: ServiceDayBlueprint.render(@service_days)
      end

      # GET /service_days/::id
      def show
        if @service_day
          render json: ServiceDayBlueprint.render(@service_day)
        else
          render status: :not_found
        end
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

      # PUT /service_days
      def update
        if @service_day
          if @service_day.update(service_day_params)
            render json: ServiceDayBlueprint.render(@service_day)
          else
            render json: @service_day.errors, status: :unprocessable_entity
          end
        else
          render status: :not_found
        end
      end

      # DELETE /service_days
      def destroy
        if @service_day
          @service_day.destroy
          render status: :no_content
        else
          render status: :not_found
        end
      end

      private

      def set_service_day
        @service_day = policy_scope(ServiceDay).find(params[:id])
      end

      def set_service_days
        @service_days = if params[:business].present?
                          service_days_for_business
                        else
                          service_days_for_user
                        end
      end

      def service_days_for_business
        policy_scope(
          ServiceDay
          .left_outer_joins(:attendances)
          .includes(:attendances, { child: { business: :user } })
          .joins(child: :business)
          .where(children: { businesses: Business.find(params[:business].split(',')) })
          .order('children.last_name')
          .for_week(filter_date)
        )
      end

      def service_days_for_user
        policy_scope(
          ServiceDay
          .left_outer_joins(:attendances)
          .includes(:attendances, { child: { business: :user } })
          .joins(child: :business)
          .order('children.last_name')
          .for_week(filter_date)
        )
      end

      def date
        service_day_params[:date]
          .to_date
          .in_time_zone(Child.find_by(id: service_day_params[:child_id])&.timezone)
      end

      def filter_date
        params[:filter_date] ? Time.zone.parse(params[:filter_date]) : Time.current
      end

      def service_day_params
        params.require(:service_day).permit(:date, :absence_type, :child_id, business: [])
      end
    end
  end
end
