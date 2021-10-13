class AddDeletedAtToApprovals < ActiveRecord::Migration[6.1]
  def change
    add_column :approvals, :deleted_at, :date
  end
end
