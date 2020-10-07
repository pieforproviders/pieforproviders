class DropAgencies < ActiveRecord::Migration[6.0]
  def change
    drop_table :agencies, id: :uuid do |t|
      t.string :name, null: false
      t.string :state, null: false
      t.boolean :active, null: false, default: true

      t.index %i[name state], unique: true

      t.timestamps
    end
  end
end
