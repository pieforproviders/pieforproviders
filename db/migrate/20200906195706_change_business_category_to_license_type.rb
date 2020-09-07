class ChangeBusinessCategoryToLicenseType < ActiveRecord::Migration[6.0]
  # frozen_string_literal: true

  def up
    add_column :businesses, :license_type, :license_types
    execute <<-SQL
     UPDATE businesses SET license_type = cast(category AS license_types);
    SQL

    remove_column :businesses, :category
  end

  def down
    add_column :businesses, :category, :string
    execute <<-SQL
     UPDATE businesses SET category = license_type;
    SQL

    remove_column :businesses, :license_type
  end
end
