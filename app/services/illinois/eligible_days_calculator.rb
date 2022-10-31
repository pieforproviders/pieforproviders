# frozen_string_literal: true

module Illinois
  # Service to calculate eligible days
  class EligibleDaysCalculator
    attr_reader :child, :date, :full_time

    def initialize(date:, child:, full_time: true)
      @date = date
      @child = child
      @full_time = full_time
    end

    def call
      calculate_time_in_days
    end

    private

    def calculate_time_in_days
      weeks_in_month = DateService.weeks_in_month(date)
      approval = monthly_approval
      return 0 if approval.nil?

      total_days = days_by_time_type(approval) * weeks_in_month

      total_days <= eligible_days_by_business ? total_days : eligible_days_by_business
    end

    def days_by_time_type(approval)
      return approval.full_days_approved_per_week if full_time
      return approval.part_days_approved_per_week unless full_time
    end

    def monthly_approval
      child.active_approval(date).illinois_approval_amounts.find do |approval|
        approval.month.month == date.month && approval.month.year == date.year
      end
    end

    def eligible_days_by_business
      days_in_month = DateService.days_in_month(date)
      days_in_month - closed_days_by_month
    end

    def closed_days_by_month
      closed_days = 0
      date.to_date.all_month.each do |day|
        closed_days += 1 unless child.business.eligible_by_date?(day)
      end
      closed_days
    end
  end
end
