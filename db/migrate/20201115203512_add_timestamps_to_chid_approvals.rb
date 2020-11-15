class AddTimestampsToChidApprovals < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :child_approvals, default: DateTime.now
    change_column_default :child_approvals, :created_at, from: DateTime.now, to: nil
    change_column_default :child_approvals, :updated_at, from: DateTime.now, to: nil
  end
end
