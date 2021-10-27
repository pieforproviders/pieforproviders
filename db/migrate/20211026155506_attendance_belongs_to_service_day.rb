class AttendanceBelongsToServiceDay < ActiveRecord::Migration[6.1]
  def change
    add_reference :attendances, :service_day, type: :uuid, foreign_key: true
    Attendance.all.each do |attendance|
      attendance.service_day = ServiceDay.find_or_create_by!(
        child: attendance.child,
        date: attendance.check_in.in_time_zone(attendance.user.timezone).at_beginning_of_day
      )
      attendance.save!
    end
  end
end
