class CreateStateTimeRules < ActiveRecord::Migration[6.1]
  def change
    create_table :state_time_rules, id: :uuid do |t|
      t.string :name
      t.references :state, null: false, foreign_key: true, type: :uuid
      t.integer :min_time
      t.integer :max_time

      t.timestamps
    end
  end
end
