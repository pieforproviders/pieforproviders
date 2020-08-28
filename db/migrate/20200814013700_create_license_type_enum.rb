class CreateLicenseTypeEnum < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE license_types AS ENUM ('licensed_center', 'licensed_family_home',
        'licensed_group_home', 'license_exempt_home', 'license_exempt_center');
    SQL
  end
  def down
    execute <<-SQL
      DROP TYPE license_types;
    SQL
  end
end
