class MoveAbsencesToServiceDays < ActiveRecord::Migration[6.1]
  def change
    Attendance.all.where.not(absence: nil) do |attendance|
      attendance.service_day.update(absence_type: attendance.absence)
    end
  end
end
