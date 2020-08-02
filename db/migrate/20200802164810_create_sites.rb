# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration[6.0]
  def change
    create_table :sites, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :name, null: false
      t.string :address, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false
      t.string :county, null: false
      t.string :slug, null: false
      t.string :qris_rating
      t.uuid :business_id, null: false

      t.timestamps
    end
    add_index :sites, %i[name business_id], unique: true
  end
end
