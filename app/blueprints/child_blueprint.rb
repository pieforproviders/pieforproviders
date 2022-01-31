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
      service_days = child.active_child_approval(options[:filter_date])&.service_days&.with_attendances
      attended_days = service_days.non_absences
      absent_days = service_days.absences
      Nebraska::DashboardCase.new(
        child: child,
        filter_date: options[:filter_date],
        attended_days: attended_days,
        absent_days: absent_days
      )
    end
  end
end
