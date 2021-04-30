class AddInactiveInfoToChild < ActiveRecord::Migration[6.1]
  def change
    add_column :children, :last_active_date, :date
    add_column :children, :inactive_reason, :string
  end
end
