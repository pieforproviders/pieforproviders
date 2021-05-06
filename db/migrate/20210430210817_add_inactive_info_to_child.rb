class AddInactiveInfoToChild < ActiveRecord::Migration[6.1]
  def change
    add_column :children, :last_active_date, :date
    add_column :children, :inactive_reason, :string
    add_column :children, :deleted, :boolean, null: false, default: false
  end
end
