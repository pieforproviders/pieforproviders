class RemoveOptInPhoneFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :opt_in_phone, :boolean, null: false, default: true
  end
end
