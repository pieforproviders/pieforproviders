class RemoveOldMigrations < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::SchemaMigration.delete_all
    ActiveRecord::DataMigration.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
