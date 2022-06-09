# frozen_string_literal: true

#Run everyday
desc 'Create and clear notifications'
task daily_notifications: :environment do
	count = 0
	Approval.where('expires_on <= ?', 30.days.after).each do |approval|
		NotificationGeneratorJob.perform_now(approval: approval)
		count += 1
	end
	puts "Saved " + count.to_s + " notifications"

	count = 0
	Notification.joins(:approval).where('approvals.expires_on < ?', 0.days.ago).each do |notification|
		notification.destroy
		count += 1
	end

	puts "Destroyed " + count.to_s + " notifications"
end