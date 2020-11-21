class CreateLookupCounties < ActiveRecord::Migration[6.0]
  def change
    create_table :lookup_counties, id: :uuid do |t|
      t.uuid :state_id
      t.string :abbr
      t.string :name, null: false
      t.string :county_seat

      t.timestamps
    end
    add_index :lookup_counties, :name
    add_index :lookup_counties, :state_id
    add_index :lookup_counties, %i[state_id name], unique: true
  end
end
