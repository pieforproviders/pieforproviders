class AddNebraskaLimits < ActiveRecord::Migration[6.1]
  def change
    create_table :nebraska_limits, id: :uuid do |t|
      t.integer :amount, null: false
      t.time :effective, null: false
      t.time :expires, default: nil
      t.string :frequency, null: false
      t.string :type, null: false

      t.timestamps
    end
  end
end
