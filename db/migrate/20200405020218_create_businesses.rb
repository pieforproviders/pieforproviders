class CreateBusinesses < ActiveRecord::Migration[6.0]
  def change
    create_table :businesses, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :category, null: false
      t.string :name, null: false
      t.uuid :user_id, null: false

      t.timestamps
    end
    add_index :businesses, :user_id
  end
end
