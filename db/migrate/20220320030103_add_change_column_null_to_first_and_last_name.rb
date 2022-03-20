class AddChangeColumnNullToFirstAndLastName < ActiveRecord::Migration[6.1]
  def up
    change_column_null :children, :first_name, false
    change_column_null :children, :last_name, false
  end

  def down
    change_column_null :children, :first_name, true
    change_column_null :children, :last_name, true
  end
end
