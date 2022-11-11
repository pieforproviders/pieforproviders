# frozen_string_literal: true

module Illinois
  # Service to get tags for a given service day
  class TagsCalculator
    attr_reader :service_day

    def initialize(service_day:)
      @service_day = service_day
    end

    def call
      tags
    end

    private

    def tags
      [tag_two_days, tag_full, tag_partial, tag_absence].compact
    end

    def tag_partial
      partial? ? '1 partDay' : nil
    end

    def tag_full
      full_day? ? '1 daily' : nil
    end

    def tag_two_days
      two_days? ? '2 fullDays' : nil
    end

    def partial?
      return false unless @service_day.total_time_in_care

      @service_day.total_time_in_care < 5.hours || full_and_part_day?
    end

    def full_day?
      return false unless @service_day.total_time_in_care

      (@service_day.total_time_in_care > 5.hours && @service_day.total_time_in_care < 12.hours) || full_and_part_day?
    end

    def full_and_part_day?
      return false unless @service_day.total_time_in_care

      @service_day.total_time_in_care > 12.hours && @service_day.total_time_in_care < 17.hours
    end

    def two_days?
      return false unless @service_day.total_time_in_care

      @service_day.total_time_in_care > 17.hours
    end

    def tag_absence
      @service_day.absence? ? 'absence' : nil
    end
  end
end
