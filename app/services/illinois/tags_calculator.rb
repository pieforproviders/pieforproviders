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
      []
    end

    private

    def tags
      [tag_hourly, tag_daily, tag_absence].compact
    end

    def tag_hourly
      hourly? || daily_plus_hourly? || daily_plus_hourly_max? ? "#{tag_hourly_amount} hourly" : nil
    end

    def tag_daily
      daily? || daily_plus_hourly? || daily_plus_hourly_max? ? "#{tag_daily_amount} daily" : nil
    end

    def tag_hourly_amount
      a = Nebraska::Daily::HoursDurationCalculator.new(total_time_in_care: @service_day.total_time_in_care).call
      a.to_i == a ? a.to_i.to_s : a.to_s
    end

    def tag_daily_amount
      Nebraska::Daily::DaysDurationCalculator.new(total_time_in_care: @service_day.total_time_in_care).call&.to_s
    end

    def tag_absence
      @service_day.absence? ? 'absence' : nil
    end

    def hourly?
      return false unless @service_day.total_time_in_care

      @service_day.total_time_in_care <= (5.hours + 45.minutes)
    end

    def daily?
      return false unless @service_day.total_time_in_care

      @service_day.total_time_in_care > (5.hours + 45.minutes) && @service_day.total_time_in_care <= 10.hours
    end

    def daily_plus_hourly?
      return false unless @service_day.total_time_in_care

      @service_day.total_time_in_care > 10.hours && @service_day.total_time_in_care <= 18.hours
    end

    def daily_plus_hourly_max?
      return false unless @service_day.total_time_in_care

      @service_day.total_time_in_care > 18.hours
    end
  end
end
