class CreateChildren < ActiveRecord::Migration[6.0]
  def change
    create_table :children, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :ccms_id
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :full_name, null: false
      t.date :date_of_birth, null: false
      t.uuid :user_id, null: false

      t.timestamps
    end
    add_index :children, :user_id
  end
end
