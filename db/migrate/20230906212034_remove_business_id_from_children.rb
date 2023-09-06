class RemoveBusinessIdFromChildren < ActiveRecord::Migration[6.1]
  def change
    remove_column :children, :business_id, :integer
  end
end
