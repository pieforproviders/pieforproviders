class DropLocations < ActiveRecord::Migration[6.0]
  def change
    remove_column :subsidy_rules, :county_id, type: :uuid, null: false, foreign_key: { to_table: :lookup_counties }, index: true
    remove_column :subsidy_rules, :state_id, type: :uuid, null: false, foreign_key: { to_table: :lookup_counties }, index: true
    drop_table :lookup_states, id: :uuid do |t|
      t.string :abbr, limit: 2, null: false
      t.string :name, null: false

      t.index :abbr, unique: true
      t.index :name, unique: true

      t.timestamps
    end

    drop_table :lookup_counties, id: :uuid do |t|
      t.uuid :state_id
      t.string :abbr
      t.string :name, null: false
      t.string :county_seat

      t.index :name
      t.index :state_id
      t.index %i[state_id name], unique: true

      t.timestamps
    end

    drop_table :lookup_cities, id: :uuid do |t|
      t.string :name, null: false
      t.uuid :state_id,  foreign_key: true, null: false
      t.uuid :county_id, foreign_key: true

      t.index :name
      t.index :state_id
      t.index %i[name state_id], unique: true
      t.index :county_id

      t.timestamps
    end

    drop_table :lookup_zipcodes, id: :uuid do |t|
      t.string :code, null: false
      t.uuid :state_id
      t.uuid :county_id
      t.uuid :city_id
      t.string :area_code
      t.decimal :lat, precision: 15, scale: 10
      t.decimal :lon, precision: 15, scale: 10

      t.index :code, unique: true
      t.index :county_id
      t.index :state_id
      t.index :city_id
      t.index %i[state_id city_id]

      t.timestamps
    end
  end
end
