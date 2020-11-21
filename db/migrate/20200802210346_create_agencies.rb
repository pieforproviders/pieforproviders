class CreateAgencies < ActiveRecord::Migration[6.0]
  def change
    create_table :agencies, id: :uuid do |t|
      t.string :name, null: false
      t.string :state, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :agencies, [:name, :state], unique: true
  end
end
