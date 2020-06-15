class AddUniquePhoneIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :phone_number, unique: true
  end
end
