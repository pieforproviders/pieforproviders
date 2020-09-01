class CreateLookupCities < ActiveRecord::Migration[6.0]
  def change
    create_table :lookup_cities, id: :uuid do |t|
      t.string :name, null: false
      t.uuid :state_id,  foreign_key: true, null: false
      t.uuid :county_id, foreign_key: true

      t.timestamps
    end

    add_index :lookup_cities, :name
    add_index :lookup_cities, :state_id
    add_index :lookup_cities, %i[name state_id], unique: true
    add_index :lookup_cities, :county_id
  end
end
