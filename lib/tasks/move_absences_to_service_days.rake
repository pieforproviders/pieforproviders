# frozen_string_literal: true

# Move all existing absences to service days
task move_absences_to_service_days: :environment do
  Rails.logger.level = 3
  attendances = Attendance.all.where.not(absence: nil)
  puts "Records: #{attendances.size}"
  batch_number = 0
  attendances.in_batches do |attendance_batch|
    puts "Batch #{batch_number}, attendances #{batch_number * 1000} - #{(batch_number * 1000) + 999}"
    attendance_batch.each(&:destroy!)
    batch_number += 1
  end
end
