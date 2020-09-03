class AddNotNullConstraintToUsersGreetingName < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :greeting_name, false
  end
end
