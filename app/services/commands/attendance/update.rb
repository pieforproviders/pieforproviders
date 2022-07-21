# frozen_string_literal: true

module Commands
  module Attendance
    # Command pattern to update an attendance, associate or update its service day,
    # recalculate the ServiceDay calculated fields and recalculate the Dashboard
    class Update
      attr_reader :absence_type, :attendance, :check_in, :check_out, :child

      def initialize(attendance:, absence_type:, check_in:, check_out:)
        @attendance = attendance
        @child = attendance.child
        timezone = @child.timezone
        @check_in = check_in.in_time_zone(timezone)
        @check_out = check_out&.in_time_zone(timezone)
        @absence_type = absence_type
      end

      def update
        return if check_in == attendance.check_in &&
                  check_out == attendance.check_out &&
                  absence_type == attendance.service_day.absence_type

        update_attendance_and_service_day
      end

      private

      def update_attendance_and_service_day
        ActiveRecord::Base.transaction do
          updated_attendance = attendance.update!(updated_attendance_params)

          # TODO: move this to service day command
          unless attendance.service_day == new_service_day = new_or_existing_service_day
            associate_service_day(new_service_day: new_service_day)
          end

          update_service_day
          updated_attendance
        end
      end

      def updated_attendance_params
        {
          check_in: check_in,
          check_out: check_out,
          child_approval: child_approval
        }
      end

      def new_or_existing_service_day
        ServiceDay::Create.new(child: child, date: check_in.at_beginning_of_day).create
      end

      def child_approval
        child.active_child_approval(check_in)
      end

      def associate_service_day(new_service_day:)
        old_service_day = attendance.service_day
        attendance.update!(service_day: new_service_day)
        old_service_day.attendances.empty? && old_service_day.destroy!
      end

      def update_service_day
        ServiceDay::Update.new(service_day: attendance.service_day, absence_type: absence_type).update
        # To Be Implemented:
        # DashboardCalculator.new(service_day: service_day).call
      end
    end
  end
end
