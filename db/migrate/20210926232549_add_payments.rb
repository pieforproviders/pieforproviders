class AddPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.date :month, null: false
      t.decimal :amount, null: false
      t.references :child_approval, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
