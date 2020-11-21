class MakeBusinessNonNullableRemoveUserFromChildren < ActiveRecord::Migration[6.0]
  def change
    remove_column :children, :user_id, :uuid, foreign_key: true
    change_column_null :children, :business_id, false
  end
end
