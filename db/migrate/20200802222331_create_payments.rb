class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments, id: :uuid do |t|
      t.date :paid_on, null: false
      t.date :care_started_on, null: false
      t.date :care_finished_on, null: false
      t.monetize :amount, null: false, default: 0
      t.string :slug, null: false
      t.monetize :discrepancy, amount: { null: true, default: nil }, currency: { null: true, default: nil }
      t.uuid :site_id, null: false
      t.uuid :agency_id, null: false

      t.timestamps
    end
    add_index :payments, %i[site_id agency_id]
    add_index :payments, :site_id
  end
end
