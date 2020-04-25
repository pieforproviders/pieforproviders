class NoNullsOnOrgs < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :organization, :string, null: false
  end
  def down
    change_column :users, :organization, :string, null: true
  end
end
