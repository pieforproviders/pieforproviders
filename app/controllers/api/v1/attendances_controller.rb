# frozen_string_literal: true

module Api
  module V1
    # API for user attendances
    class AttendancesController < Api::V1::ApiController
      # GET /attendances
      def index
        @attendances = policy_scope(Attendance).for_week(filter_date)

        render json: AttendanceBlueprint.render(@attendances.includes({ child_approval: :child }))
      end

      private

      def filter_date
        if params[:filter_date]
          Time.zone.parse(params[:filter_date])&.at_end_of_day
        else
          Time.current.at_end_of_day
        end
      end
    end
  end
end
