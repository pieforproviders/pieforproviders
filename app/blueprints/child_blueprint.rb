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
      child.approvals.active_on_date(options[:filter_date]).first&.case_number
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
    field :attendance_risk do |child, options|
      child.attendance_risk(options[:filter_date])
    end
    field :absences do |child, options|
      # Uses a feature flag in the child model methods
      absences = child.absences(options[:filter_date])
      if absences
        absences.to_s.include?('of') ? absences : "#{absences} of 5"
      else
        '0 of 5'
      end
      # nebraska restricts absences to 5 allowed
      # the csv imports for temporary dashboard cases will
      # probably have "of 5" in their string, so we don't want it to duplicate
    end
    field :case_number do |child, options|
      child.approvals.active_on_date(options[:filter_date]).first&.case_number
    end
    field :family_fee do |child, options|
      format('%.2f', child.nebraska_family_fee(options[:filter_date]))&.to_f
    end
    field :earned_revenue do |child, options|
      format('%.2f', child.nebraska_earned_revenue(options[:filter_date]))&.to_f
    end
    field :estimated_revenue do |child, options|
      format('%.2f', child.nebraska_estimated_revenue(options[:filter_date]))&.to_f
    end
    field :full_days do |child, options|
      # Uses a feature flag in the child model methods
      child.nebraska_full_days(options[:filter_date])&.to_f&.to_s
    end
    field :hours do |child, options|
      # Uses a feature flag in the child model methods
      child.nebraska_hours(options[:filter_date])&.to_f&.to_s
    end
    field :hours_attended do |child, options|
      # Uses a feature flag in the child model methods
      authorized_weekly_hours = child.active_child_approval(options[:filter_date]).authorized_weekly_hours
      hours_attended = child.nebraska_weekly_hours_attended(options[:filter_date])
      if hours_attended.respond_to?(:positive?) && hours_attended >= 0
        "#{hours_attended} of #{authorized_weekly_hours}"
      else
        hours_attended&.to_s
      end
    end
  end
end
