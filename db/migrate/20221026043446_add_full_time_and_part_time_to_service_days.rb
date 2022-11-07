class AddFullTimeAndPartTimeToServiceDays < ActiveRecord::Migration[6.1]
  def change
    add_column :service_days, :full_time, :integer, default: 0
    add_column :service_days, :part_time, :integer, default: 0
    add_index :service_days, :full_time
    add_index :service_days, :part_time
  end
end
