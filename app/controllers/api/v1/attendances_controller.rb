# frozen_string_literal: true

module Api
  module V1
    # API for user attendances
    class AttendancesController < Api::V1::ApiController
      before_action :set_attendance, only: %i[update destroy]

      # GET /attendances
      def index
        @attendances = policy_scope(Attendance).for_week(filter_date)

        render json: AttendanceBlueprint.render(
          @attendances.includes({ child_approval: :child }),
          view: :with_child
        )
      end

      def update
        # if the attendance is updated and either there are no service_day_attributes or
        # the update w/ the service_day_attributes works, render successfully
        # otherwise render errors

        if update_command
          render json: AttendanceBlueprint.render(
            @attendance,
            view: :with_child
          )
        else
          Rails.logger.info @attendance.errors.messages
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

      def update_command
        # TODO: move this to the service day update and remove nested attributes here
        absence_type = if service_day_params&.keys&.include?('absence_type')
                         service_day_params['absence_type']
                       else
                         @attendance.service_day.absence_type
                       end
        Commands::Attendance::Update.new(
          attendance: @attendance,
          check_in: attendance_params['check_in'] || @attendance.check_in,
          check_out: attendance_params['check_out'] || @attendance.check_out,
          absence_type: absence_type
        ).update
      end

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
        if service_day_params
          params
            .require(:attendance)
            .merge(service_day_attributes: service_day_params)
            .permit(:check_in, :check_out, service_day_attributes: %i[absence_type id])
        else
          params.require(:attendance).permit(:check_in, :check_out)
        end
      end

      def service_day_params
        service_day_id = params.dig(:attendance, :service_day_attributes, :id).presence || @attendance&.service_day&.id
        params.dig(:attendance, :service_day_attributes)&.merge(id: service_day_id)&.permit(:id, :absence_type)
      end
    end
  end
end
