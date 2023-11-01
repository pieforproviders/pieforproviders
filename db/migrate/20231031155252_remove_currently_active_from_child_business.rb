class RemoveCurrentlyActiveFromChildBusiness < ActiveRecord::Migration[7.0]
  def change
    remove_column :child_businesses, :currently_active, :boolean
  end
end
