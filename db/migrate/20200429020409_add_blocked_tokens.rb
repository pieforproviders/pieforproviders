class AddBlockedTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_tokens, id: :uuid do |t|
      t.string :jti, null: false
      t.datetime :expiration, null: false
    end
    add_index :blocked_tokens, :jti
  end
end
