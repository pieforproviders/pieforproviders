class AddInacivityFieldsToApprovals < ActiveRecord::Migration[6.1]
  def change
    add_column :approvals, :active, :boolean, default: true, null: false
    add_column :approvals, :inactive_reason, :string
  end
end
