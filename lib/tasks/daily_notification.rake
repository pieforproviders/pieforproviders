# frozen_string_literal: true

# Run everyday, will delete all existing notifications, query most recent approvals for 
# each child, and then generate new notifications for each
desc 'Create and clear notifications'
task daily_notifications: :environment do
  NotificationGeneratorJob.perform_later
end
