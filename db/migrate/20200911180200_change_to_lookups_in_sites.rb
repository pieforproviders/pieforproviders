class ChangeToLookupsInSites < ActiveRecord::Migration[6.0]
  def up
    add_column :sites, :state_id, :uuid, foreign_key: { to_table: :lookup_states }, index: true
    add_column :sites, :county_id, :uuid, foreign_key: { to_table: :lookup_counties }, index: true
    add_column :sites, :city_id, :uuid, foreign_key: { to_table: :lookup_cities }, index: true
    add_column :sites, :zip_id, :uuid, foreign_key: { to_table: :lookup_zipcodes }, index: true

    execute <<-SQL
      UPDATE sites SET state_id = (SELECT id from lookup_states  where abbr=sites.state);
      UPDATE sites SET county_id = (SELECT id from lookup_counties where (name=sites.county AND state_id=sites.state_id));
      UPDATE sites SET city_id = (SELECT id from lookup_cities where (name=sites.city AND state_id=sites.state_id));
      UPDATE sites SET zip_id = (SELECT id from lookup_zipcodes where (code=sites.zip AND city_id=sites.city_id AND state_id=sites.state_id));
    SQL

    change_column :sites, :state_id, :uuid, null: false
    change_column :sites, :county_id, :uuid, null: false
    change_column :sites, :city_id, :uuid, null: false
    change_column :sites, :zip_id, :uuid, null: false

    remove_column :sites, :state
    remove_column :sites, :county
    remove_column :sites, :city
    remove_column :sites, :zip
  end

  def down
    add_column :sites, :state, :string
    add_column :sites, :county, :string
    add_column :sites, :city, :string
    add_column :sites, :zip, :string

    execute <<-SQL
      UPDATE sites SET state = (SELECT abbr from lookup_states where id=sites.state_id);
      UPDATE sites SET county = (SELECT name from lookup_counties where id=sites.county_id);
      UPDATE sites SET city = (SELECT name from lookup_cities where lookup_cities.id=sites.city_id);
      UPDATE sites SET zip = (SELECT code from lookup_zipcodes where lookup_zipcodes.id=sites.zip_id);
    SQL

    change_column :sites, :state, :string, null: false
    change_column :sites, :county, :string, null: false
    change_column :sites, :city, :string, null: false
    change_column :sites, :zip, :string, null: false

    remove_column :sites, :state_id
    remove_column :sites, :county_id
    remove_column :sites, :city_id
    remove_column :sites, :zip_id
  end
end
