class AddWonderschoolIdToChild < ActiveRecord::Migration[6.1]
  def change
    add_column :children, :wonderschool_id, :string
  end
end
