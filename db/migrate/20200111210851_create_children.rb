class CreateChildren < ActiveRecord::Migration[6.0]
  def change
    create_table :children, id: :uuid do |t|
      t.string :full_name
      t.string :greeting_name
      t.date :date_of_birth
      t.boolean :active, default: true
    end
  end
end
