class AddIllinoisApprovalAmounts < ActiveRecord::Migration[6.0]
  def change
    create_table :illinois_approval_amounts, id: :uuid do |t|
      t.date :month, null: false
      t.integer :part_days_approved_per_week
      t.integer :full_days_approved_per_week
      t.references :child_approval, type: :uuid, null: false, index: true, foreign_key: true

      t.timestamps
    end
  end
end
