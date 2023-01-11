# frozen_string_literal: true

module Illinois
  # A case for display in the Illinois Dashboard
  # rubocop:disable Metrics/ClassLength
  class DashboardCase
    attr_reader :absent_days,
                :business,
                :child,
                :filter_date,
                :schedules,
                :eligible_days,
                :attended_days

    ATTENDANCE_THRESHOLD = 69.5
    def initialize(child:, filter_date:, eligible_days: nil, attended_days: nil)
      @child = child
      @filter_date = filter_date
      @business = child.business
      @schedules = child&.schedules
      @eligible_days = eligible_days
      @attended_days = attended_days
    end

    def case_number
      Appsignal.instrument_sql(
        'dashboard_case.case_number'
      ) do
        child.approvals.active_on(filter_date).first&.case_number
      end
    end

    def guaranteed_revenue
      return 0 if no_attendances

      # binding.pry 

      if (child.attendance_rate(filter_date) * 100) >= ATTENDANCE_THRESHOLD
        earned_revenue_above_threshold * business.il_quality_bump
      else
        earned_revenue_below_threshold * business.il_quality_bump
      end
    end

    def earned_revenue_above_threshold
      ((eligible_part_days * business_rate('part_day')) +
        (eligible_full_days * business_rate('full_day'))).round(2)
    end

    def earned_revenue_below_threshold
      ((part_days_by_date * business_rate('part_day')) +
        (full_days_by_date * business_rate('full_day'))).round(2)
    end

    def eligible_part_days
      child.eligible_part_days_by_month(filter_date)
    end

    def eligible_full_days
      child.eligible_full_days_by_month(filter_date)
    end

    def no_attendances
      part_days_by_date.zero? && full_days_by_date.zero?
    end

    def potential_revenue
      rand(500.00..1000.00).round(2)
    end

    def max_approved_revenue
      rand(1000.00..2000.00).round(2)
    end

    def attendance_rate
      if business.license_center?
        business.attendance_rate(child, filter_date, eligible_days, attended_days)
      else
        child.attendance_rate(filter_date)
      end
    end

    def part_days_attended
      "#{part_days_by_date} (of #{child.eligible_part_days_by_month(filter_date)} eligible)"
    end

    def full_days_attended
      "#{full_days_by_date} (of #{child.eligible_full_days_by_month(filter_date)} eligible)"
    end

    def attendance_risk
      child.attendance_risk(filter_date)
    end

    def full_days_by_date
      child.service_days.for_month(filter_date).map(&:full_time).compact.reduce(:+) || 0
    end

    def part_days_by_date
      child.service_days.for_month(filter_date).map(&:part_time).compact.reduce(:+) || 0
    end

    def child_approvals
      Appsignal.instrument_sql(
        'dashboard_case.child_approvals'
      ) do
        @child_approvals ||= child&.child_approvals&.with_approval
      end
    end

    def approval
      Appsignal.instrument_sql(
        'dashboard_case.approval'
      ) do
        @approval ||= child&.approvals&.active_on(filter_date)&.first
      end
    end

    def child_approval
      Appsignal.instrument_sql(
        'dashboard_case.child_approval'
      ) do
        @child_approval ||= approval&.child_approvals&.find_by(child: child)
      end
    end

    def approval_effective_on
      Appsignal.instrument_sql(
        'dashboard_case.approval_effective_on'
      ) do
        @approval_effective_on ||= child_approval&.effective_on
      end
    end

    def approval_expires_on
      Appsignal.instrument_sql(
        'dashboard_case.approval_expires_on'
      ) do
        @approval_expires_on ||= child_approval&.expires_on
      end
    end

    def business_rate(rate_type)
      rates.find do |rate|
        rate.rate_type == rate_type
      end&.amount || 0
    end

    def rates
      IllinoisRate.for_case(
        filter_date,
        child.age_in_months(filter_date),
        business
      )
    end
  end
  # rubocop:enable Metrics/ClassLength
end
