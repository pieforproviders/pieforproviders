class RemoveBillableOccurrencesAndAssociateAttendancesToChildApproval < ActiveRecord::Migration[6.0]
  def change
    add_reference :attendances, :child_approval, type: :uuid, null: false, foreign_key: true, index: true
  end
end
