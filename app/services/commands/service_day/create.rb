# frozen_string_literal: true

module Commands
  module ServiceDay
    # Command pattern to find or create a service_day
    class Create
      attr_reader :child, :date

      def initialize(child:, date:)
        @child = child
        @date = date
      end

      def create
        ActiveRecord::Base.transaction do
          service_day = ::ServiceDay.find_or_initialize_by(child: child, date: date.at_beginning_of_day)
          service_day
        end
      end
    end
  end
end
