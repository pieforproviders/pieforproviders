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
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).attendance_risk
    end
    field :absences do |child, options|
      "#{Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).absences} of 5"
    end
    field :case_number do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).case_number
    end
    field :family_fee do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).family_fee
    end
    field :earned_revenue do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).earned_revenue&.to_f&.round(2)
    end
    field :estimated_revenue do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).estimated_revenue&.to_f
    end
    field :full_days do |child, options|
      # TODO: change this to return the raw data type (float)
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).full_days&.to_f&.to_s
    end
    field :hours do |child, options|
      # TODO: change this to return the raw data type (integer)
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).hours&.to_f&.to_s
    end
    field :full_days_remaining do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).full_days_remaining&.to_i
    end
    field :hours_remaining do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).hours_remaining&.to_f
    end
    field :full_days_authorized do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).full_days_authorized
    end
    field :hours_authorized do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).hours_authorized&.to_f
    end
    field :hours_attended do |child, options|
      Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date]).hours_attended
    end
  end
end
