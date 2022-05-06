# frozen_string_literal: true

module Api
  module V1
    # API for user attendances
    class AttendancesController < Api::V1::ApiController
      before_action :set_attendance, only: %i[update destroy]

      # GET /attendances
      def index
        @attendances = policy_scope(Attendance).for_week(filter_date)

        render json: AttendanceBlueprint.render(@attendances.includes({ child_approval: :child }))
      end

      def update
        # if the attendance is updated and either there are no service_day_attributes or
        # the update w/ the service_day_attributes works, render successfully
        # otherwise render errors
        if @attendance.update(attendance_params.except(:service_day_attributes)) &&
           (
             !attendance_params['service_day_attributes'] ||
             update_service_day(attendance_params['service_day_attributes'])
           )
          render json: AttendanceBlueprint.render(@attendance)
        else
          render json: @attendance.errors, status: :unprocessable_entity
        end
      end

      def destroy
        # hard delete
        if @attendance
          @attendance.destroy
          render status: :no_content
        else
          render status: :not_found
        end
      end

      private

      def filter_date
        if params[:filter_date]
          Time.zone.parse(params[:filter_date])&.at_end_of_day
        else
          Time.current.at_end_of_day
        end
      end

      def set_attendance
        @attendance = policy_scope(Attendance).find(params[:id])
      end

      def attendance_params
        params.require(:attendance).permit(:absence, :check_in, :check_out, service_day_attributes: [:absence_type])
      end

      def update_service_day(params)
        # update the existing service_day for the attendance; stack all errors
        # from an unsuccessful update onto the attendance object
        @attendance.service_day.update(params)
        if @attendance.service_day.errors.present?
          @attendance.service_day.errors.messages.map do |k, v|
            @errors[k] = v
          end
          false
        else
          true
        end
      end
    end
  end
end
