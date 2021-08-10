class ChangeChildApprovalRateAssociationToPolymorphic < ActiveRecord::Migration[6.1]
  def change
    remove_reference :child_approvals, :illinois_rate
    add_reference :child_approvals, :rate, polymorphic: true, type: :uuid
  end
end
