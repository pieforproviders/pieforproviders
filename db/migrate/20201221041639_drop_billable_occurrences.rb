class DropBillableOccurrences < ActiveRecord::Migration[6.0]
  def change
    drop_table :billable_occurrences
  end
end
