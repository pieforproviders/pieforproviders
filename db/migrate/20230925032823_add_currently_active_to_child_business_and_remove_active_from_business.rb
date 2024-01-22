class AddCurrentlyActiveToChildBusinessAndRemoveActiveFromBusiness < ActiveRecord::Migration[6.0] 
  def change
    add_column :child_businesses, :currently_active, :boolean, default: false
    remove_column :businesses, :active, :boolean
  end
end

