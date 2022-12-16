# frozen_string_literal: true

module Illinois
  # Serializer for dashboard cases
  class DashboardCaseBlueprint < Blueprinter::Base
    field :case_number
    field :attendance_risk
    field :full_days_attended
    field :part_days_attended
    field :attendance_rate
    field :guaranteed_revenue do |dashboard_case, _options|
      dashboard_case.guaranteed_revenue&.to_f
    end
    field :potential_revenue
    field :max_approved_revenue
    field :approval_effective_on
    field :approval_expires_on
  end
end
