# frozen_string_literal: true

# Serializer for children
class ChildBlueprint < Blueprinter::Base
  identifier :id

  field :active
  field :last_active_date
  field :inactive_reason
  field :first_name
  field :last_name
  field :wonderschool_id
  field :business_name do |child, _options|
    child.business.name
  end

  view :cases do
    association :business, blueprint: BusinessBlueprint
    field :state
    field :case_number do |child|
      child&.approvals&.first&.case_number
    end
  end

  view :illinois_dashboard do
    association :illinois_dashboard_case, blueprint: Illinois::DashboardCaseBlueprint do |child, options|
      options[:filter_date] ||= Time.current
      child_approval = child&.active_child_approval(options[:filter_date])
      service_days = child&.service_days&.for_period(child_approval.effective_on, child_approval.expires_on)
      attended_days = service_days&.non_absences
      Illinois::DashboardCase.new(
        child: child,
        filter_date: options[:filter_date],
        attended_days: attended_days
      )
    end
  end

  view :nebraska_dashboard do
    association :nebraska_dashboard_case, blueprint: Nebraska::DashboardCaseBlueprint do |child, options|
      options[:filter_date] ||= Time.current
      child_approval = child&.active_child_approval(options[:filter_date])
      service_days = child&.service_days&.for_period(child_approval.effective_on, child_approval.expires_on)
      attended_days = service_days&.non_absences
      absent_days = service_days&.absences
      Nebraska::DashboardCase.new(
        child: child,
        filter_date: options[:filter_date],
        attended_days: attended_days,
        absent_days: absent_days
      )
    end
  end
end