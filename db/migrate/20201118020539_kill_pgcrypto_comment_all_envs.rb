class KillPgcryptoCommentAllEnvs < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.connection.execute('COMMENT ON EXTENSION pgcrypto IS NULL;')
  end

  def down
    ActiveRecord::Base.connection.execute("COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';")
  end
end
