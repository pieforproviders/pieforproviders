class DropAgencies < ActiveRecord::Migration[6.0]
  def change
    drop_table :agencies, id: :uuid do |t|
      t.string :name, null: false
      t.uuid :state_id, null: false
      t.boolean :active, null: false, default: true

      t.index %i[name state_id], unique: true

      t.timestamps
    end
  end
end
