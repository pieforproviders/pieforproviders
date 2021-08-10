class AddAuthorizedWeeklyHoursToChildApproval < ActiveRecord::Migration[6.1]
  def change
    add_column :child_approvals, :authorized_weekly_hours, :integer
  end
end
