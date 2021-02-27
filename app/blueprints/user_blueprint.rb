# frozen_string_literal: true

# Serializer for users
class UserBlueprint < Blueprinter::Base
  identifier :id
  field :greeting_name
  field :language
  field :state do |user|
    user.admin? ? 'NE' : user.state
  end

  view :illinois_dashboard do
    field(:as_of) do |user, options|
      # if there are no attendances, the rates are as of today
      (user.latest_attendance_in_month(options[:from_date]) || DateTime.now.in_time_zone(user.timezone)).strftime('%m/%d/%Y')
    end
    association :businesses, blueprint: BusinessBlueprint, view: :illinois_dashboard
    excludes :id, :greeting_name, :language, :state
  end

  view :nebraska_dashboard do
    field(:as_of) do |user, options|
      # if there are no attendances, the rates are as of today
      (user.latest_attendance_in_month(options[:from_date]) || DateTime.now.in_time_zone(user.timezone)).strftime('%m/%d/%Y')
    end
    association :businesses, blueprint: BusinessBlueprint, view: :nebraska_dashboard
    field :max_revenue do
      'N/A'
    end
    field :total_approved do
      'N/A'
    end
    excludes :id, :greeting_name, :language, :state
  end
end
