class CreateLookupZipcodes < ActiveRecord::Migration[6.0]
  def change
    create_table :lookup_zipcodes, id: :uuid do |t|
      t.string :code, null: false
      t.uuid :state_id
      t.uuid :county_id
      t.uuid :city_id
      t.string :area_code
      t.decimal :lat, precision: 15, scale: 10
      t.decimal :lon, precision: 15, scale: 10

      t.timestamps
    end

    add_index :lookup_zipcodes, :code, unique: true
    add_index :lookup_zipcodes, :county_id
    add_index :lookup_zipcodes, :state_id
    add_index :lookup_zipcodes, :city_id
    add_index :lookup_zipcodes, %i[state_id city_id]
  end
end
