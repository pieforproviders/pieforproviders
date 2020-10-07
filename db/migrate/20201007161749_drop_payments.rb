class DropPayments < ActiveRecord::Migration[6.0]
  def change
    drop_table :child_case_cycle_payments, id: :uuid do |t|
      t.monetize :amount, null: false
      t.monetize :discrepancy, amount: { null: true, default: nil }, currency: { null: true, default: 'USD' }
      t.references :payment, type: :uuid, null: false, foreign_key: true
      t.references :child_case_cycle, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    drop_table :payments, id: :uuid do |t|
      t.date :paid_on, null: false
      t.date :care_started_on, null: false
      t.date :care_finished_on, null: false
      t.monetize :amount, null: false
      t.monetize :discrepancy, amount: { null: true, default: nil }, currency: { null: true, default: 'USD' }
      t.uuid :agency_id, null: false

      t.timestamps
    end
  end
end
