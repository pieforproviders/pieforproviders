class AddActiveToBusinesses < ActiveRecord::Migration[6.1]
  def change
    add_column :businesses, :active, :boolean, default: true, null: false
  end
end
