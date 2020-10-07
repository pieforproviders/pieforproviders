class DropSites < ActiveRecord::Migration[6.0]
  def change
    
    remove_column :payments, :site_id, :uuid, null: false
    drop_table :sites, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :name, null: false
      t.string :address, null: false
      t.uuid :city_id, null: false, foreign_key: { to_table: :lookup_cities }
      t.uuid :state_id, null: false, foreign_key: { to_table: :lookup_states }
      t.uuid :county_id, null: false, foreign_key: { to_table: :lookup_counties }
      t.uuid :zip_id, null: false, foreign_key: { to_table: :lookup_zipcodes }
      t.string :slug, null: false
      t.string :qris_rating
      t.uuid :business_id, null: false

      t.index %i[name business_id], unique: true
      t.index :state_id
      t.index :city_id
      t.index :county_id
      t.index :zip_id

      t.timestamps
    end

    remove_reference :attendances, :child_site, type: :uuid, null: false, foreign_key: true
    drop_table :child_sites, id: :uuid do |t|
      t.uuid :child_id, null: false
      t.uuid :site_id, null: false
      t.date :started_care
      t.date :ended_care

      t.index %i[child_id site_id]

      t.timestamps
    end
  end
end
