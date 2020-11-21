class CreateCaseCycles < ActiveRecord::Migration[6.0]
  def change
    create_table :case_cycles, id: :uuid do |t|
      t.string :case_number
      t.monetize :copay
      t.string :slug, null: false, index: { unique: true }
      t.date :submitted_on, null: false
      t.date :effective_on
      t.date :notified_on
      t.date :expires_on

      t.timestamps
    end
  end
end
