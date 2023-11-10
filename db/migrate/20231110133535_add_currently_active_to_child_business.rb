class AddCurrentlyActiveToChildBusiness < ActiveRecord::Migration[7.0]
  def up
    add_column :child_businesses, :currently_active, :boolean, default: false
    
    ChildBusiness.update_all(currently_active: true)
  end

  def down
    remove_column :child_businesses, :currently_active
  end
end
