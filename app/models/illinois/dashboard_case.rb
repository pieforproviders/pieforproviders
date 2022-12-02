# frozen_string_literal: true

module Illinois
  # A case for display in the Illinois Dashboard
  class DashboardCase
    attr_reader :absent_days,
                :business,
                :child,
                :filter_date,
                :schedules

    def initialize(child:, filter_date:, attended_days:)
      @child = child
      @filter_date = filter_date
      @attended_days = attended_days
      @business = child.business
      @schedules = child&.schedules
    end

    def case_number
      Appsignal.instrument_sql(
        'dashboard_case.case_number'
      ) do
        child.approvals.active_on(filter_date).first&.case_number
      end
    end

    def guaranteed_revenue
      rand(0.00..500.00).round(2)
    end

    def potential_revenue
      rand(500.00..1000.00).round(2)
    end

    def max_approved_revenue
      rand(1000.00..2000.00).round(2)
    end

    def attendance_rate
      child.attendance_rate(filter_date)
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
  end
end