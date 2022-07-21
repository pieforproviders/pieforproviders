# frozen_string_literal: true

module Commands
  module Attendance
    # Command pattern to create an attendance, find or create its ServiceDay,
    # recalculate the ServiceDay calculated fields and recalculate the Dashboard
    class Create
      attr_reader :service_day

      def initialize(check_in:, child_id:, check_out: nil, wonderschool_id: nil)
        @child_id = child_id
        @check_in = check_in.in_time_zone(timezone)
        @check_out = check_out&.in_time_zone(timezone)
        @wonderschool_id = wonderschool_id
        @service_day = new_or_existing_service_day
      end

      def create
        ActiveRecord::Base.transaction do
          created_attendance = ::Attendance.create!(attendance)

          ServiceDay::Update.new(service_day: service_day, absence_type: nil).update
          # To Be Implemented:
          # DashboardCalculator.new(service_day: service_day).call
          created_attendance
        end
      end

      private

      attr_reader :check_in, :check_out, :child_id, :wonderschool_id

      def attendance
        {
          check_in: check_in,
          check_out: check_out,
          child_approval: child_approval,
          service_day: service_day,
          wonderschool_id: wonderschool_id
        }
      end

      def child
        Child.find(child_id)
      end

      def timezone
        child.timezone
      end

      def new_or_existing_service_day
        ServiceDay::Create.new(child: child, date: check_in.at_beginning_of_day).create
      end

      def child_approval
        child.active_child_approval(check_in)
      end
    end
  end
end
