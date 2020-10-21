# frozen_string_literal: true
# frozen_string_literal: true

desc 'Remove data and schema migrations'
task remove_migrations: :environment do
  ActiveRecord::SchemaMigration.delete_all
  DataMigrate::DataSchemaMigration.delete_all
end
