class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.date :paid_on
      t.date :care_started_on
      t.date :care_finished_on
      t.monetize :amount
      t.string :slug, null: false
      t.monetize :discrepancy
      t.uuid :site_id, null: false
      t.uuid :agency_id, null: false

      t.timestamps
    end
    add_index :payments, %i[site_id agency_id]
    add_index :payments, :site_id
  end
end
