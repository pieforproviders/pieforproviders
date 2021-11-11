class RemoveEarnedRevenueFromAttendance < ActiveRecord::Migration[6.1]
  def change
    remove_column :attendances, :earned_revenue, :decimal
  end
end
