class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.boolean :active, null: false, default: true
      t.string :full_name, null: false
      t.string :greeting_name
      t.string :email, null: false
      t.string :language, null: false
      t.string :phone_type
      t.boolean :opt_in_email, null: false, default: true
      t.boolean :opt_in_phone, null: false, default: true
      t.boolean :opt_in_text, null: false, default: true
      t.string :phone
      t.boolean :service_agreement_accepted, null: false, default: false
      t.string :timezone, null: false
      t.timestamps

      t.index :email, unique: true
    end
  end
end
