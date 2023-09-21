# frozen_string_literal: true

module Commands
  module Attendance
    # Command pattern to soft delete an attendance, update or delete its attendance day,
    # recalculate the ServiceDay calculated fields and recalculate the Dashboard
    class Delete
      attr_reader :attendance, :service_day

      def initialize(attendance:)
        @attendance = attendance
        @service_day = attendance.service_day
      end

      def delete
        attendance.destroy!
        update_service_day
      end

      private

      def update_service_day
        ServiceDayCalculator.new(service_day:).call

        return unless service_day.attendances.empty?

        service_day.schedule ? service_day.update!(absence_type: 'absence') : service_day.destroy!
      end
    end
  end
end
