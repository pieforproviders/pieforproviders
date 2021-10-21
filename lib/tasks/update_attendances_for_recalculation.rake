# frozen_string_literal: true

# To fix the rate bug, we need to touch the attendance records so they automatically
# update their earned revenue
desc 'Update attendances so their rates will be recalculated correctly'
task update_attendances_for_recalculation: :environment do
  Attendance.all.each { |attendance| attendance.update!(updated_at: Time.current) }
end
