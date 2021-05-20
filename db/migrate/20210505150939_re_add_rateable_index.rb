class ReAddRateableIndex < ActiveRecord::Migration[6.1]
  def change

      add_reference :rates, :rateable, type: :uuid, polymorphic: true, index: { name: 'rateable_index' }
      add_reference :child_approvals, :rate, type: :uuid, foreign_key: true

  end
end
