# frozen_string_literal: true

# Multiple children for expiring notification? One for each kid or a single one?
class NotificationGenerator
  def call
    Approval.where('expires_on <= ?', 30.days.after).each do |approval|
      approval.child_approvals.each do |child_approval|
        generate_notification(approval.id, child_approval.child_id)
      end
    end

    Notification.joins(:approval).where('approvals.expires_on < ?', 0.days.ago).each(&:destroy)
  end

  private

  def generate_notification(approval_id, child_id)
    ActiveRecord::Base.transaction do
      Notification.create(approval_id: approval_id, child_id: child_id)
    end
  end
end
