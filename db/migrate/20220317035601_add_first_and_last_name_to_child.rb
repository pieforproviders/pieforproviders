class AddFirstAndLastNameToChild < ActiveRecord::Migration[6.1]
  def up
    add_column :children, :first_name, :string
    add_column :children, :last_name, :string

    Child.all.each do |c|
      name = c.full_name.split(' ')
      full_name = c.full_name.gsub("'", "''")
      first_name = name.first.gsub("'", "''").presence || '-'
      last_name = name.last.gsub("'", "''").presence || '-'
      ActiveRecord::Base.connection.execute("update children set first_name = '#{first_name}', last_name = '#{last_name}' where full_name = '#{full_name}'")
      # TODO: for some reason, updating the child record is executing callbacks on attendances and service days and deleting a lot of records on production data
      # I'm not sure what's triggering it after about 30 mins of investigation so I'm doing SQL directly
      # c.update!(first_name: name.first, last_name: name.last)
    end
  end

  def down
    remove_column :children, :first_name
    remove_column :children, :last_name
  end
end
