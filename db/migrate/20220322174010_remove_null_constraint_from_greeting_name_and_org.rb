class RemoveNullConstraintFromGreetingNameAndOrg < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :greeting_name, :string, null: true
    change_column :users, :organization, :string, null: true
  end
end
