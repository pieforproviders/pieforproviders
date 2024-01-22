class RemoveActiveFromChildBusiness < ActiveRecord::Migration[6.0]
  def change
    remove_column :child_businesses, :active, :boolean
  end
end

