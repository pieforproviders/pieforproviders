class AddDeletedAtToIllinoisApprovalAmounts < ActiveRecord::Migration[6.1]
  def change
    add_column :illinois_approval_amounts, :deleted_at, :date
  end
end
