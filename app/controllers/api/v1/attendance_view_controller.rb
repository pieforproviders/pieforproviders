# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/LineLength
module Api
  module V1
    # Service for dashboard table info
    class AttendanceViewController < ApiController
      def index
        filter_date = params[:filter_date].to_date
        current_date = Date.current
        start_date = filter_date == current_date ? (current_date.at_beginning_of_week - 1.day).to_s : filter_date.to_s
        end_date = filter_date == current_date ? current_date.at_end_of_week.to_s : (filter_date + 1.day).at_end_of_week.to_s

        business_ids = params[:business_ids]&.split(',')

        attendance_info = AttendanceInfoService.new(start_date, end_date, business_ids)
        response = attendance_info.call
        render json: response
      end
    end
  end
end
# rubocop: enable Metrics/LineLength\
# rubocop: enable Metrics/AbcSize
