class AddServiceDays < ActiveRecord::Migration[6.1]
  def change
    create_table :service_days, id: :uuid do |t|
      t.datetime :date, null: false
      t.references :child, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
