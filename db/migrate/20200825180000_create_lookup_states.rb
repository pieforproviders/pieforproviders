class CreateLookupStates < ActiveRecord::Migration[6.0]
  def change
    create_table :lookup_states, id: :uuid do |t|
      t.string :abbr, limit: 2, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :lookup_states, :abbr, unique: true
    add_index :lookup_states, :name, unique: true
  end
end
