class CreateAgencies < ActiveRecord::Migration[6.0]
  def change
    create_table :agencies, id: :uuid do |t|
      t.string :name, null: false
      t.string :state
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
