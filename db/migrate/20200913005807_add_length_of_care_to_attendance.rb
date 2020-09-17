class AddLengthOfCareToAttendance < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      create type lengths_of_care as enum ('part_day', 'full_day', 'full_plus_part_day', 'full_plus_full_day');
    SQL

    add_column :attendances, :length_of_care, :lengths_of_care, null: false, default: 'full_day'
  end

  def down
    remove_column :attendances, :length_of_care

    execute <<-SQL
      drop type lengths_of_care;
    SQL
  end
end
