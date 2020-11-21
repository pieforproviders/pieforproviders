class RemoveFirstAndLastNameFromChildren < ActiveRecord::Migration[6.0]
  def change
    remove_index :children, column: [:first_name, :last_name, :date_of_birth, :user_id], unique: true, name: :unique_children
    add_index :children, [:full_name, :date_of_birth, :user_id], unique: true, name: :unique_children
    remove_column :children, :first_name, :string
    remove_column :children, :last_name, :string
  end
end
