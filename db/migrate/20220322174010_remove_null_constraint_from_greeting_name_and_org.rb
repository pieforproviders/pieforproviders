class RemoveNullConstraintFromGreetingNameAndOrg < ActiveRecord::Migration[6.1]
  def change
    change_column_null :users, :greeting_name, false
    change_column_null :users, :organization, false
  end
end
