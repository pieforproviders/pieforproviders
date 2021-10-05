class AddDeletedAtToNebraskaApprovalAmounts < ActiveRecord::Migration[6.1]
  def change
    add_column :nebraska_approval_amounts, :deleted_at, :date
  end
end
