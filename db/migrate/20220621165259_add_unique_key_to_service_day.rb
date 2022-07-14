class AddUniqueKeyToServiceDay < ActiveRecord::Migration[6.1]
  def change
    add_index :service_days, %i[child_id date], unique: true
  end
end
