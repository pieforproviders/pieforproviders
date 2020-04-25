class AddOrganizationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :organization, :string, null: false
  end
end
