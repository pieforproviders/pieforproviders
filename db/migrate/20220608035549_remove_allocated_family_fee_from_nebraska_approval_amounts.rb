class RemoveAllocatedFamilyFeeFromNebraskaApprovalAmounts < ActiveRecord::Migration[6.1]
  def up
    remove_column :nebraska_approval_amounts, :allocated_family_fee
  end

  def down
    add_column :nebraska_approval_amounts, :allocated_family_fee, :decimal
  end
end
