# frozen_string_literal: true

# Move all existing absences to service days
task :remove_absences, [:initial_date] => [:environment] do |_t, args|
  attendances = ServiceDay.where('created_at > ?', args[:initial_date])
  duplicates = attendances.select(:child_id).group(:child_id).having('count(*) > 1')
  child_ids = duplicates.map(&:child_id)
  to_remove_absences = []

  child_ids.each do |child_id|
    child_attendances = attendances.where("child_id = ? and (absence_type is null or absence_type = '')", child_id)
    child_attendances.each do |attendance|
      attendance_date = attendance.date
      result = attendances.where(
        'child_id = ? and (date between ? and ?) and absence_type is not null',
        child_id,
        attendance_date.beginning_of_day,
        attendance_date.end_of_day
      )
      next if result.empty?

      to_remove_absences << result.first
    end
  end
  to_remove_absences.each(&:destroy)
end
