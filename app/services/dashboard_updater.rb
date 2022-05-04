# frozen_string_literal: true

# Service to update a dashboard record after an attendance is created
# or updated
class DashboardUpdater
  attr_reader :attendance, :state

  def initialize(attendance:)
    @attendance = attendance
    @state = attendance.child.state
  end

  def call
    update_dashboard
  end

  # def update_dashboard
  #   Nebraska::DashboardUpdater.new(attendance: attendance).call if state == 'NE'
  # end
end
