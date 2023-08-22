class CreateBusinessClosures < ActiveRecord::Migration[6.1]
  def change
    create_table :business_closures, id: :uuid do |t|
      t.boolean :is_holiday
      t.date :date

      t.references :business, type: :uuid, null: false, index: true, foreign_key: true

      t.index %i[business_id date], unique: true, name: :unique_business_closure
      t.timestamps
    end
  end
end
