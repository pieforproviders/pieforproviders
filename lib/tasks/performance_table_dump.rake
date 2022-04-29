# frozen_string_literal: true

# This dumps all dev tables to JSON in the fixtures/files/prod_like_seeds folder
task performance_table_dump: :environment do
  if Rails.env.development?
    sql = "
    CREATE or REPLACE FUNCTION copy_table(table_name text)
    RETURNS void AS $$
    begin
      execute 'COPY (
        SELECT json_agg(row_to_json(' || table_name || ')) :: text
          FROM ' || table_name || '
      ) TO ''/Users/katedonaldson/Projects/pieforproviders/spec/fixtures/files/prod_like_seeds/'||table_name||'.json''';
    end
    $$ language 'plpgsql';


    CREATE or REPLACE FUNCTION copy_loop(rows_arr text[])
    RETURNS void AS $$
    declare
      crtRow text;
    begin
      ForEach crtRow in array rows_arr
      LOOP
         perform copy_table(crtRow);
      end loop;
    end
    $$ language 'plpgsql';

    select copy_loop(ARRAY['users', 'businesses', 'approvals', 'child_approvals', 'children', 'nebraska_rates', 'schedules', 'service_days', 'attendances', 'nebraska_approval_amounts'])
    "
    ActiveRecord::Base.connection.execute(sql)
  else
    puts 'Error dumping tables to json: this environment does not allow for dumping tables to json'
  end
end
