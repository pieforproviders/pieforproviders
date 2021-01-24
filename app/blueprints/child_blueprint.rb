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
    field :attendance_risk do
      %w[on_track exceeded_limit at_risk].sample
    end
    field :absences do
      total_absences = rand(0..10).round
      "#{rand(0..total_absences)} of #{total_absences}"
    end
    field :case_number do |child, options|
      child.approvals.active_on_date(options[:from_date].in_time_zone(child.timezone)).case_number
    end
    field :earned_revenue do
      rand(0.00..1000.00).round(2)
    end
    field :estimated_revenue do
      rand(1000.00..2000.00).round(2)
    end
    field :full_days do
      total_days = rand(0..25).round
      "#{rand(0..total_days)} of #{total_days}"
    end
    field :full_name
    field :hours do
      total_hours = rand(0.0..10.0).round
      "#{rand(0.0..total_hours).round(2)} of #{total_hours}"
    end
    field :transportation_revenue do
      "#{rand(0..30)} trips - #{Money.new(rand(0..100_000)).format}"
    end
    exclude :id
  end
end
