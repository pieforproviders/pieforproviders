# frozen_string_literal: true

# Serializer for children
class ChildBlueprint < Blueprinter::Base
  identifier :id

  field :active
  field :last_active_date
  field :inactive_reason
  field :full_name

  view :illinois_dashboard do
    field :case_number do |child, options|
      child.approvals.active_on(options[:filter_date]).first&.case_number
    end
    field :attendance_risk do |child, options|
      child.attendance_risk(options[:filter_date])
    end
    field(:attendance_rate) do |child, options|
      child.attendance_rate(options[:filter_date])
    end
    field :guaranteed_revenue do |_child, _options|
      rand(0.00..500.00).round(2)
    end
    field :potential_revenue do |_child, _options|
      rand(500.00..1000.00).round(2)
    end
    field :max_approved_revenue do |_child, _options|
      rand(1000.00..2000.00).round(2)
    end
  end

  view :nebraska_dashboard do
    association :nebraska_dashboard_case, blueprint: Nebraska::DashboardCaseBlueprint do |child, options|
      options[:filter_date] ||= Time.current
      # TODO: We are currently limiting this by the active child approval that applies to the filter date
      # We don't currently account for what happens if a child's approval/child_approval changes in the
      # middle of the month
      service_days = child.active_child_approval(options[:filter_date])&.service_days&.includes(:attendances)
      approval_absences = service_days.absences

      Nebraska::DashboardCase.new(child: child,
                                  filter_date: options[:filter_date],
                                  service_days: service_days,
                                  approval_absences: approval_absences)
    end
  end
end
