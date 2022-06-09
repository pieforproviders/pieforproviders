# frozen_string_literal: true

# Run everyday
# Expected Behavior: Run everyday, check for existing notifications and see another if there is another
# approval for that child (check for renewal of approval). Only time there is a notification is
# if there is an approval expiring within 30 days
desc 'Create and clear notifications'
task daily_notifications: :environment do
  NotificationGeneratorJob.perform_later
end
