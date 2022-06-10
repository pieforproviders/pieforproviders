# frozen_string_literal: true

# Multiple children for expiring notification? One for each kid or a single one?
class NotificationGenerator
  def call
    Notification.destroy_all
    sql = "select approval_id, child_id, max(expires_on) from " \
          "(select * from child_approvals inner join approvals on child_approvals.approval_id = approvals.id) "\
          "as bigtable group by approval_id, child_id;"
    ActiveRecord::Base.connection.execute(sql).each do |record|
      if record["max"].between?(0.days.after, 30.days.after)
        generate_notification(record["approval_id"], record["child_id"])
      end
    end
  end

  private

  def generate_notification(approval_id, child_id)
    ActiveRecord::Base.transaction do
      Notification.create(approval_id: approval_id, child_id: child_id)
    end
  end
end