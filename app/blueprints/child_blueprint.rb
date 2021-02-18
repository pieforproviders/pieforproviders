# frozen_string_literal: true

# Serializer for children
class ChildBlueprint < Blueprinter::Base
  identifier :id

  view :illinois_dashboard do
    field :full_name
    field :case_number do |child, options|
      child.approvals.active_on_date(options[:from_date].in_time_zone(child.timezone)).case_number
    end
    field :attendance_risk do |child, options|
      child.attendance_risk(options[:from_date])
    end
    field(:attendance_rate) do |child, options|
      child.attendance_rate(options[:from_date])
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
    exclude :id
  end

  view :nebraska_dashboard do
    field :attendance_risk do |child|
      child.temporary_nebraska_dashboard_case.attendance_risk.presence
    end
    field :absences do |child|
      child.temporary_nebraska_dashboard_case.absences.presence
    end
    field :case_number do |child, options|
      child.approvals.active_on_date(options[:from_date].in_time_zone(child.timezone)).case_number
    end
    field :earned_revenue do |child|
      child.temporary_nebraska_dashboard_case.earned_revenue.presence&.to_f || 0.0
    end
    field :estimated_revenue do |child|
      child.temporary_nebraska_dashboard_case.estimated_revenue.presence&.to_f || 0.0
    end
    field :full_days do |child|
      child.temporary_nebraska_dashboard_case.full_days.presence
    end
    field :full_name
    field :hours do |child|
      child.temporary_nebraska_dashboard_case.hours.presence
    end
    field :transportation_revenue do |child|
      child.temporary_nebraska_dashboard_case.transportation_revenue.presence
    end
    exclude :id
  end
end
