# frozen_string_literal: true

module Nebraska
  # Service to calculate eligible days
  class EligibleDaysCalculator
    attr_reader :child, :date, :full_time

    def initialize(date:, child:, full_time: true, until_given_date: false)
      @date = date
      @child = child
      @full_time = full_time
      @until_given_date = until_given_date
    end

    def call
      calculate_time_in_days
    end

    def date_range
      @until_given_date ? (date.beginning_of_month.to_date..date.to_date) : date.to_date.all_month
    end

    def closed_days_by_month_until_date
      closed_days = 0
      date_range.each do |day|
        child_business = @child.child_businesses.find_by(currently_active: true)
        active_business = businesses.find(child_business.business_id)
        closed_days += 1 unless active_business.eligible_by_date?(day)
      end
      closed_days
    end

    private

    def calculate_time_in_days
      approval = monthly_approval
      @child_approval = child.child_approvals.find_by(approval_id: approval.id)

      return 0 if @child_approval.nil?

      total_days = days_by_time_type

      [total_days, eligible_days_by_business].min
    end

    def days_by_time_type
      return full_time_days if full_time

      part_time_days unless full_time
    end

    def monthly_approval
      child.approvals.each do |approval|
        return approval if approval.date_in_range?(date)
      end
    end

    def eligible_days_by_business
      days_in_month = DateService.days_in_month(date)
      days_in_month - closed_days_by_month
    end

    def closed_days_by_month
      closed_days = 0
      date.to_date.all_month.each do |day|
        child_business = child.child_businesses.find_by(currently_active: true)
        active_business = businesses.find(child_business.business_id)
        closed_days += 1 unless active_business.eligible_by_date?(day)
      end
      closed_days
    end

    def full_time_days
      @child_approval.full_days || 0
    end

    def part_time_days
      (@child_approval.part_days&./ 12) || 0
    end
  end
end
