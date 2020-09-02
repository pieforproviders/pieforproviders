class AddUserIdToCaseCycles < ActiveRecord::Migration[6.0]
  def change
    add_reference :case_cycles, :user, type: :uuid, null: false, foreign_key: true
  end
end
