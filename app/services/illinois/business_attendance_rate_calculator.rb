# frozen_string_literal: true

# Service to calculate a family's attendance rate
module Illinois
  # Calculates IL rate by business
  class BusinessAttendanceRateCalculator
    def initialize(business, filter_date)
      @business = business
      @filter_date = filter_date
    end

    def eligible_attendances
      eligible_days = []
      children_checked = []

      @business.approvals.active_on(@filter_date).each do |approval|
        approval.children.each do |child|
          eligible_days << eligible_days_by_child(child) unless children_checked.include?(child.id)
          children_checked << child.id
        end
      end

      eligible_days.flatten.compact.sum
    end

    def attended_days
      attendances_sum = 0

      active_approvals.each do |active_approval|
        attendances_sum += sum_attendances(active_approval)
      end

      attendances_sum
    end

    private

    def eligible_days_by_child(child)
      eligible_days = []

      eligible_days << Illinois::EligibleDaysCalculator.new(date: @filter_date, child:).call
      eligible_days << Illinois::EligibleDaysCalculator.new(date: @filter_date, child:, full_time: false).call

      eligible_days
    end

    def attendances(approval)
      approval.attendances.for_month(@filter_date)
    end

    def active_approvals
      @business.approvals.active.active_on(@filter_date)
    end

    def sum_attendances(approval)
      attendances(approval).illinois_part_days.count +
        attendances(approval).illinois_full_days.count +
        (attendances(approval).illinois_full_plus_part_days.count * 2) +
        (attendances(approval).illinois_full_plus_full_days.count * 2)
    end
  end
end
