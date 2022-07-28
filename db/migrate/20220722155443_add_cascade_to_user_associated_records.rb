class AddCascadeToUserAssociatedRecords < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :businesses, :users
    add_foreign_key :businesses, :users, on_delete: :cascade
  end
end
