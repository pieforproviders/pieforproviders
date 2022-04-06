class RemoveFullNameFromChild < ActiveRecord::Migration[6.1]
  def change
    remove_column :children, :full_name
  end
end
