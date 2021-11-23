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
        params[:filter_date] ? Time.zone.parse(params[:filter_date]) : nil
      end
    end
  end
end
