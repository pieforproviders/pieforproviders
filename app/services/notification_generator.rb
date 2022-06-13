# frozen_string_literal: true

# Multiple children for expiring notification? One for each kid or a single one?
class NotificationGenerator
  def call
    approvals_without_notification = Approval.where.missing(:notifications).where('expires_on between ? and ?',
                                                                                  0.days.after,
                                                                                  30.days.after)
    if approvals_without_notification.length.positive?
      approvals_without_notification.each do |record|
        record.children.each { |child| generate_notification(record.id, child.id) }
      end
    end

    delete_notifications
  end

  private

  def delete_notifications
    Approval.all.each do |record|
      next if record.expires_on.between?(0.days.after, 30.days.after)

      record.children.each do |child|
        child.notification&.destroy
      end
    end
  end

  def generate_notification(approval_id, child_id)
    ActiveRecord::Base.transaction do
      Notification.create(approval_id: approval_id, child_id: child_id)
    end
  end
end
