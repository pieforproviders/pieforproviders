class RemoveUserIdFromChildCaseCycles < ActiveRecord::Migration[6.0]
  def change
    remove_column :child_case_cycles, :user_id, :uuid
  end
end
