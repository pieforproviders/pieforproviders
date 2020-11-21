class AddBillableOccurrences < ActiveRecord::Migration[6.0]
  def up
    create_table :billable_occurrences, id: :uuid do |t|
      t.references :billable, polymorphic: true, index: { name: :billable_index }
      t.references :child_approval, type: :uuid, foreign_key: true, null: false

      t.timestamps
    end

    create_table :billable_occurrence_rate_types, id: :uuid do |t|
      t.references :billable_occurrence, type: :uuid, foreign_key: true
      t.references :rate_type, null: false, type: :uuid, foreign_key: true
    end

    remove_column :attendances, :starts_on, :date
    remove_column :attendances, :attendance_duration, :duration_definitions
    remove_column :attendances, :check_in, :time
    remove_column :attendances, :check_out, :time
    add_column :attendances, :check_in, :datetime
    add_column :attendances, :check_out, :datetime

    execute <<-SQL.squish
      drop type duration_definitions;
    SQL
  end

  def down
    execute <<-SQL.squish
      create type duration_definitions as enum ('part_day', 'full_day', 'full_plus_part_day', 'full_plus_full_day');
    SQL
    remove_column :attendances, :check_in, :datetime
    remove_column :attendances, :check_out, :datetime
    add_column :attendances, :check_in, :time
    add_column :attendances, :check_out, :time
    add_column :attendances, :attendance_duration, :duration_definitions
    add_column :attendances, :starts_on, :date

    drop_table :billable_occurrence_rate_types
    drop_table :billable_occurrences
  end
end
