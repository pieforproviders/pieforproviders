class AddDurationToSchedules < ActiveRecord::Migration[6.1]
  def change
    add_column :schedules, :duration, :interval
    Schedule.all.each do |schedule|
      schedule.update!(duration: Tod::Shift.new(schedule.start_time, schedule.end_time).duration)
    end
    remove_column :schedules, :start_time, :time
    remove_column :schedules, :end_time, :time
  end
end
