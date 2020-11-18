class ExtensionFix < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.connection.execute('COMMENT ON EXTENSION pgcrypto IS NULL;') if Rails.env.development?
  end

  def down
    ActiveRecord::Base.connection.execute("COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';") if Rails.env.development?
  end
end
