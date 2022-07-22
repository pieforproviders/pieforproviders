# frozen_string_literal: true

# This is meant to delete a user by email and all records associated with their account
desc 'Delete all records associated with a user\'s account'
task delete_users: :environment do
  user = User.find_by(email: ENV.fetch('EMAIL', nil))
  Approval.where(id: user.approvals.map(&:id)).destroy_all
  user.destroy
end
