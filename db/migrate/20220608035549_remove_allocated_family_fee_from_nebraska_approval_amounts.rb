class RemoveAllocatedFamilyFeeFromNebraskaApprovalAmounts < ActiveRecord::Migration[6.1]
  def change
    remove_column :nebraska_approval_amounts, :allocated_family_fee, :decimal
  end
end
