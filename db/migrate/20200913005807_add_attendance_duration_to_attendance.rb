class AddAttendanceDurationToAttendance < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL.squish
      create type duration_definitions as enum ('part_day', 'full_day', 'full_plus_part_day', 'full_plus_full_day');
    SQL

    add_column :attendances, :attendance_duration, :duration_definitions, null: false, default: 'full_day'
  end

  def down
    remove_column :attendances, :attendance_duration

    execute <<-SQL.squish
      drop type duration_definitions;
    SQL
  end
end
