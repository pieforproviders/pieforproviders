# frozen_string_literal: true

# Job to seed attendances on Demo
class SeedDemoAttendancesJob < ApplicationJob
  def perform
    return unless ENV.fetch('HEROKU_APP_NAME', nil) == 'pie-app-demo'

    DemoAttendanceSeeder.call
  end
end
