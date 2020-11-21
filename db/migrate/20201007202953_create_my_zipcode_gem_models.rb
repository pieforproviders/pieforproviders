class CreateMyZipcodeGemModels < ActiveRecord::Migration[6.0]
  def change
    # States Table
    create_table :states, id: :uuid do |t|
      t.string :abbr, limit: 2, index: true
      t.string :name
      t.timestamps
    end

    # Counties Table
    create_table :counties, id: :uuid do |t|
      t.references :state, type: :uuid, null: false, foreign_key: true, index: true
      t.string :abbr
      t.string :name, index: true
      t.string :county_seat
      t.timestamps
    end

    # Zipcodes Table
    create_table :zipcodes, id: :uuid do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :city
      t.references :state, type: :uuid, null: false, foreign_key: true, index: true
      t.references :county, type: :uuid, null: false, foreign_key: true, index: true
      t.string :area_code
      t.decimal :lat, precision: 15, scale: 10
      t.decimal :lon, precision: 15, scale: 10
      t.timestamps
    end

    add_index :zipcodes, %i[lat lon]
  end
end
