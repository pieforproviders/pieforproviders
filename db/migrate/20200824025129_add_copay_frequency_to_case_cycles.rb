class AddCopayFrequencyToCaseCycles < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      create type copay_frequency as enum ('daily', 'weekly', 'monthly');
    SQL

    add_column :case_cycles, :copay_frequency, :copay_frequency, null: false
  end

  def down
    remove_column :case_cycles, :copay_frequency

    execute <<-SQL
      drop type copay_frequency;
    SQL
  end
end
