class AddShortCodeToAllTables < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :slug, :string
    add_column :businesses, :slug, :string
    add_column :children, :slug, :string

    add_index :users, :slug, unique: true
    add_index :businesses, [:name, :user_id], unique: true
    add_index :businesses, :slug, unique: true
    add_index :children, :slug, unique: true
    add_index :children, [:first_name, :last_name, :date_of_birth, :user_id], unique: true, name: :unique_children
  end
end
