class CreateHolidays < ActiveRecord::Migration[6.1]
  def change
    create_table :holidays, id: :uuid do |t|
      t.string :name
      t.date :date

      t.index %i[name date], unique: true, name: :unique_holiday
      t.timestamps
    end
  end
end
