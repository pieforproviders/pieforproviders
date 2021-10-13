class AddDeletedAtToChildApprovals < ActiveRecord::Migration[6.1]
  def change
    add_column :child_approvals, :deleted_at, :date
  end
end
