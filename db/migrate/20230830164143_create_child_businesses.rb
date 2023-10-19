class CreateChildBusinesses < ActiveRecord::Migration[6.1]
  def change
    create_table :child_businesses, id: :uuid do |t|
      t.references :child, null: false, foreign_key: true, type: :uuid
      t.references :business, null: false, foreign_key: true, type: :uuid
      t.boolean :active

      t.timestamps
    end
  end
end
