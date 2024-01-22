class PopulateChildBusinessesTable < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      INSERT INTO child_businesses (child_id, business_id, active, created_at, updated_at)
      SELECT id, business_id, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM children
      WHERE business_id IS NOT NULL
    SQL
  end

  def down
    execute "DELETE FROM child_businesses"
  end
end
