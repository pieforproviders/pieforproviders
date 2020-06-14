class RenamePhoneTypesOnUserTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :phone, :phone_number
    rename_column :users, :mobile, :phone_type
  end
end
