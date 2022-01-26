# frozen_string_literal: true

module Api
  module V1
    # API for user attendances
    class AttendancesController < Api::V1::ApiController
      before_action :set_attendance, only: %i[update]

      # GET /attendances
      def index
        @attendances = policy_scope(Attendance).for_week(filter_date)

        render json: AttendanceBlueprint.render(@attendances.includes({ child_approval: :child }))
      end

      def update
        if @attendance.update(attendance_params)
          render json: AttendanceBlueprint.render(@attendance)
        else
          render json: @attendance.errors, status: :unprocessable_entity
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
        params.require(:attendance).permit(%i[absence check_in check_out])
      end
    end
  end
end
