class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.boolean :active, default: true
      t.string :county
      t.date :date_of_birth
      t.string :email
      t.string :full_name
      t.string :greeting_name
      t.string :language
      t.boolean :okay_to_text, default: true
      t.boolean :okay_to_email, default: true
      t.boolean :okay_to_phone, default: true
      t.boolean :opt_in_text, default: true
      t.boolean :opt_in_email, default: true
      t.boolean :opt_in_phone, default: true
      t.string :phone
      t.boolean :service_agreement_accepted, default: true
      t.string :timezone
      t.string :zip
      # re: the data model, password and confirmation is all handled by devise
    end
  end
end
