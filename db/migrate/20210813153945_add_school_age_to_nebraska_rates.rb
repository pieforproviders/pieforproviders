class AddSchoolAgeToNebraskaRates < ActiveRecord::Migration[6.1]
  def change
    add_column :nebraska_rates, :school_age, :boolean, default: false
    change_column_null :nebraska_rates, :max_age, true, nil
    change_column_null :nebraska_rates, :county, true, nil
  end
end
