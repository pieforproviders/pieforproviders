class CreateUserChildren < ActiveRecord::Migration[6.0]
  def change
    create_table :user_children, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :child, null: false, foreign_key: true, type: :uuid
      t.string :relationship
    end
  end
end
