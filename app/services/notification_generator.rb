# frozen_string_literal: true

# Creates notifications for each approval that is expiring within 30 days. Clears
# expiring notifications and any notifications that have received updated approvals
class NotificationGenerator
  def call
    sync_notifications
  end

  private

  def sync_notifications
    generate_notifications
    delete_notifications
  end

  def generate_notifications
    approvals_without_notification = Approval.where.missing(:notifications).where(expires_on: 0.days.after..30.days.after)
    return unless approvals_without_notification.length.positive?

    approvals_without_notification.each do |approval|
      approval.children.each do |child|
        generate_notification_for_child(child, approval)
      end
    end
  end

  def generate_notification_for_child(child, approval)
    return if child.approvals.where(effective_on: approval.expires_on..).presence

    generate_notification(approval.id, child.id)
  end

  def delete_notification_for_child(child, approval)
    return unless child.approvals.where(effective_on: approval.expires_on..).presence

    Notification.find_by(child: child, approval: approval).destroy
  end

  def delete_notifications
    Approval.joins(:notifications).each do |approval|
      if approval.expires_on < 0.days.after
        approval.notifications.destroy_all
        next
      end
      approval.children.each do |child|
        delete_notification_for_child(child, approval)
      end
    end
  end

  def generate_notification(approval_id, child_id)
    ActiveRecord::Base.transaction do
      Notification.create(approval_id: approval_id, child_id: child_id)
    end
  end
end
