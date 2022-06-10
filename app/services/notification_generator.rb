# frozen_string_literal: true

# Multiple children for expiring notification? One for each kid or a single one?
class NotificationGenerator
  def call
    Notification.destroy_all
    sql = 'select T1.* from (select * from child_approvals ca inner join approvals a on ca.approval_id ='\
          ' a.id) as T1 left join (select * from child_approvals ca inner join approvals a on ca.approval'\
          '_id = a.id) as T2 on (T1.child_id = T2.child_id and T1.expires_on < T2.expires_on) where T2.child_id is NULL'
    ActiveRecord::Base.connection.execute(sql).each do |record|
      if record['expires_on'].between?(0.days.after, 30.days.after)
        generate_notification(record['approval_id'], record['child_id'])
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
