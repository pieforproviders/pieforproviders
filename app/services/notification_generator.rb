# frozen_string_literal: true

# Multiple children for expiring notification? One for each kid or a single one?
class NotificationGenerator
  def call
    count = 0
    Approval.where('expires_on <= ?', 30.days.after).each do |approval|
      ActiveRecord::Base.transaction do
        Notification.create(approval_id: approval.id, child_id: @child_id)
      end
      count += 1
    end
    Rails.logger.info "Saved #{count} notifications"

    count = 0
    Notification.joins(:approval).where('approvals.expires_on < ?', 0.days.ago).each do |notification|
      notification.destroy
      count += 1
    end

    Rails.logger.info "Destroyed #{count} notifications"
    generate_notification
  end

  private

  def generate_notification
    ActiveRecord::Base.transaction do
      Notification.create(approval_id: @approval_id, child_id: @child_id)
    end
  end
end
