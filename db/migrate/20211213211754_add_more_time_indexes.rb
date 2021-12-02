class AddMoreTimeIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :illinois_rates, :effective_on
    add_index :illinois_rates, :expires_on
    add_index :nebraska_approval_amounts, :effective_on
    add_index :nebraska_approval_amounts, :expires_on
    add_index :nebraska_rates, :effective_on
    add_index :nebraska_rates, :expires_on
    add_index :attendances, :check_in
  end
end
