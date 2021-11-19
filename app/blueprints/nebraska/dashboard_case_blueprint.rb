# frozen_string_literal: true

module Nebraska
  # Serializer for dashboard cases
  class DashboardCaseBlueprint < Blueprinter::Base
    field :attendance_risk
    field :absences do |dashboard_case, _options|
      "#{dashboard_case.absences} of 5"
    end
    field :case_number
    field :family_fee
    field :earned_revenue do |dashboard_case, _options|
      dashboard_case.earned_revenue&.to_f&.round(2)
    end
    field :estimated_revenue do |dashboard_case, _options|
      dashboard_case.estimated_revenue&.to_f
    end
    field :full_days do |dashboard_case, _options|
      dashboard_case.full_days&.to_f&.to_s
    end
    field :hours do |dashboard_case, _options|
      dashboard_case.hours&.to_f&.to_s
    end
    field :full_days_remaining do |dashboard_case, _options|
      dashboard_case.full_days_remaining&.to_i
    end
    field :hours_remaining do |dashboard_case, _options|
      dashboard_case.hours_remaining&.to_f
    end
    field :full_days_authorized
    field :hours_authorized do |dashboard_case, _options|
      dashboard_case.hours_authorized&.to_f
    end
    field :hours_attended
  end
end
