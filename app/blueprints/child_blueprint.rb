# frozen_string_literal: true

# Serializer for children
class ChildBlueprint < Blueprinter::Base
  identifier :id

  view :illinois_dashboard do
    field :full_name
    field :case_number do |child, options|
      child.approvals.active_on_date(options[:from_date]).case_number
    end
    field :attendance_risk do |child, options|
      child.attendance_risk(options[:from_date])
    end
    field(:attendance_rate) do |child, options|
      child.attendance_rate(options[:from_date])
    end
    field :guaranteed_revenue do |child, _options|
      child.illinois_guaranteed_revenue
    end
    field :potential_revenue do |child, _options|
      child.illinois_potential_revenue
    end
    field :max_approved_revenue do |child, _options|
      child.illinois_max_approved_revenue
    end
    exclude :id
  end

  view :nebraska_dashboard do
    field :attendance_risk do
      'on_track'
    end
    field :absences do
      '1 of 5'
    end
    field :case_number do |child, options|
      child.approvals.active_on_date(options[:from_date]).case_number
    end
    field :earned_revenue do
      1045.32
    end
    field :estimated_revenue do
      2022.14
    end
    field :full_days do
      '14 of 15'
    end
    field :full_name
    field :hours do
      '1 of 6.5'
    end
    field :transportation_revenue do
      '30 trips - $80.00'
    end
    exclude :id
  end
end
