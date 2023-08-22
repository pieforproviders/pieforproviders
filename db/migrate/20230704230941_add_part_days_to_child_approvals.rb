class AddPartDaysToChildApprovals < ActiveRecord::Migration[6.1]
  def change
    add_column :child_approvals, :part_days, :integer
    add_column :child_approvals, :special_needs_part_day_rate, :decimal
  end
end
