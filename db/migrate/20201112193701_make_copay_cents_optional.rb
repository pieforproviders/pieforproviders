class MakeCopayCentsOptional < ActiveRecord::Migration[6.0]
  def change
    remove_monetize :approvals, :copay
    add_monetize :approvals, :copay, amount: { null: true, default: nil }
  end
end
