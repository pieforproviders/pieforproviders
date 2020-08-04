# frozen_string_literal: true

class CreateChildSites < ActiveRecord::Migration[6.0]
  def change
    create_table :child_sites, id: :uuid do |t|
      t.uuid :child_id, null: false
      t.uuid :site_id, null: false
    end
    add_index :child_sites, %i[child_id site_id]
  end
end
