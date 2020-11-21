class AddStatusToCaseCycles < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      create type case_status as enum ('submitted', 'pending', 'approved', 'denied');
    SQL

    add_column :case_cycles, :status, :case_status, null: false, default: 'submitted'
  end

  def down
    remove_column :case_cycles, :status

    execute <<-SQL
      drop type case_status;
    SQL
  end
end
