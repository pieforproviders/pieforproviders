class NoNullsOnSlugs < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :slug, :string, null: false
    change_column :businesses, :slug, :string, null: false
    change_column :children, :slug, :string, null: false
  end
  def down
    change_column :users, :slug, :string, null: true
    change_column :businesses, :slug, :string, null: true
    change_column :children, :slug, :string, null: true
  end
end
