class AddLocationsToTables < ActiveRecord::Migration[6.0]
  def change
    add_reference :businesses, :county, type: :uuid, null: false, foreign_key: true, index: true
    add_reference :businesses, :zipcode, type: :uuid, null: false, foreign_key: true, index: true
    add_reference :subsidy_rules, :county, type: :uuid, foreign_key: true, index: true
    add_reference :subsidy_rules, :state, type: :uuid, null: false, foreign_key: true, index: true
  end
end
