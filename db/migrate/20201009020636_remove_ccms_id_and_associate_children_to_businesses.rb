class RemoveCcmsIdAndAssociateChildrenToBusinesses < ActiveRecord::Migration[6.0]
  def up
    remove_index :children, column: %i[full_name date_of_birth user_id], unique: true
    remove_column :children, :ccms_id, :string
    add_reference :children, :business, type: :uuid, foreign_key: true
    add_index :children, %i[full_name date_of_birth business_id], unique: true, name: :unique_children
    change_column_null :children, :user_id, true
  end

  def down
    # change_column_null :children, :user_id, true # If we roll this back we'll need to assign users and make this nullable
    remove_index :children, column: %i[full_name date_of_birth business_id], unique: true
    remove_reference :children, :business, type: :uuid, foreign_key: true
    add_column :children, :ccms_id, :string
    add_index :children, %i[full_name date_of_birth user_id], unique: true, name: :unique_children
  end
end
