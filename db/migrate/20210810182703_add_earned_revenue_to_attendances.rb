class AddEarnedRevenueToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_column :attendances, :earned_revenue, :decimal
  end
end
