class AddEffectiveOnAndExpiresOnChildApprovals < ActiveRecord::Migration[6.1]
  def change
    add_column :child_approvals, :effective_on, :date
    add_column :child_approvals, :expires_on, :date
  end
end
