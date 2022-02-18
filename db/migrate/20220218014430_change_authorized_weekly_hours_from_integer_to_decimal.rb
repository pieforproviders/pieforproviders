class ChangeAuthorizedWeeklyHoursFromIntegerToDecimal < ActiveRecord::Migration[6.1]
  def up
    change_column :child_approvals, :authorized_weekly_hours, :decimal, precision: 5, scale: 2
  end

  def down
    change_column :child_approvals, :authorized_weekly_hours, :integer
  end
end
