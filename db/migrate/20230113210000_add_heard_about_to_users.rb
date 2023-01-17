class AddHeardAboutToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :heard_about, :string
  end
end
