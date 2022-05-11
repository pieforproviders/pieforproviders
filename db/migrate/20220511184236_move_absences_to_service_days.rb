class MoveAbsencesToServiceDays < ActiveRecord::Migration[6.1]
  def change
    Attendance.all.where.not(absence: nil).in_batches do |batch|
      batch.each do |attendance|
        attendance.service_day.schedule && attendance.service_day.update!(absence_type: attendance.absence)
        attendance.destroy!
      end
    end
  end
end
