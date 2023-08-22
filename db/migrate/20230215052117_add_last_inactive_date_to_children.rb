class AddLastInactiveDateToChildren < ActiveRecord::Migration[6.1]
  def change
    add_column :children, :last_inactive_date, :date
  end
end
