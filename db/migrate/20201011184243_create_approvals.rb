class CreateApprovals < ActiveRecord::Migration[6.0]
  def change
    create_table :approvals, id: :uuid do |t|
      t.string :case_number
      t.monetize :copay
      t.column :copay_frequency, :copay_frequency
      t.date :effective_on
      t.date :expires_on

      t.timestamps
    end

    create_table :child_approvals, id: :uuid do |t|
      t.references :subsidy_rule, type: :uuid, foreign_key: true
      t.references :approval, null: false, type: :uuid, foreign_key: true
      t.references :child, null: false, type: :uuid, foreign_key: true
    end
  end
end
