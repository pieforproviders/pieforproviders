# frozen_string_literal: true

module Commands
  module ServiceDay
    # Command pattern to update a service_day
    class Update
      attr_reader :service_day, :absence_type, :schedule, :date

      def initialize(service_day:, absence_type:, schedule: nil)
        @service_day = service_day
        @absence_type = absence_type
        @date = service_day.date
        @schedule = schedule || schedule_for_weekday
      end

      def update
        ActiveRecord::Base.transaction do
          service_day.update!(absence_type: absence_type, schedule: schedule)
          ServiceDayCalculator.new(service_day: service_day).call
        end
      end

      private

      def schedule_for_weekday
        service_day.child.schedules&.active_on(date)&.for_weekday(date.wday)&.first
      end
    end
  end
end
