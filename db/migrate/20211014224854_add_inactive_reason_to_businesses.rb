class AddInactiveReasonToBusinesses < ActiveRecord::Migration[6.1]
  def change
    add_column :businesses, :inactive_reason, :string
  end
end
