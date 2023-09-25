class RemoveActiveFromChildBusiness < ActiveRecord::Migration[6.0] # O la versión que estés utilizando
  def change
    remove_column :child_businesses, :active, :boolean
  end
end

