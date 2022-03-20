class AddFirstAndLastNameToChild < ActiveRecord::Migration[6.1]
  def up
    add_column :children, :first_name, :string
    add_column :children, :last_name, :string

    Child.all.each do |c|
      name = c.full_name.split(' ')
      c.update!(first_name: name.first, last_name: name.last)
    end
  end

  def down
    remove_column :children, :first_name
    remove_column :children, :last_name
  end
end
