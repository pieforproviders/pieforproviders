class ChangeToLookupsInAgencies < ActiveRecord::Migration[6.0]
  def up
    add_column :agencies, :state_id, :uuid, foreign_key: { to_table: :lookup_states }, index: true

    execute <<-SQL
      UPDATE agencies SET state_id = (SELECT id from lookup_states  where abbr=agencies.state);
    SQL

    change_column :agencies, :state_id, :uuid, null: false
    add_index :agencies, [:name, :state_id], unique: true

    remove_column :agencies, :state
  end

  def down
    add_column :agencies, :state, :string

    execute <<-SQL
      UPDATE agencies SET state = (SELECT abbr from lookup_states where id=agencies.state_id);
    SQL

    change_column :agencies, :state, :string, null: false
    add_index :agencies, [:name, :state], unique: true

    remove_column :agencies, :state_id
  end
end
