class CreateChildCaseCyclePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :child_case_cycle_payments, id: :uuid do |t|
      t.string :slug, null: false, index: { unique: true }
      t.monetize :amount, null: false
      t.monetize :discrepancy, amount: { null: true, default: nil }, currency: { null: true, default: 'USD' }
      t.references :payment, type: :uuid, null: false, foreign_key: true
      t.references :child_case_cycle, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
