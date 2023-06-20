class CreateStates < ActiveRecord::Migration[6.1]
  def change
    create_table :states, id: :uuid do |t|
      t.string :name
      t.string :code
      t.string :subsidy_type

      t.timestamps
    end
  end
end
