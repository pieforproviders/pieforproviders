# frozen_string_literal: true

# This is meant to simulate someone entering attendances during a month;
# it should work multiple times a month, and it should only generate
# attendances between the day it is run and the last attendance that was entered
desc 'Generate attendances this month'
task attendances: :environment do
  if Rails.application.config.allow_seeding
    generate_attendances
  else
    puts 'Error seeding attendances: this environment does not allow for seeding attendances'
  end
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
def generate_attendances
  Child.all.each do |child|
    last_attendance_check_out ||= child.attendances.presence&.order(check_in: :desc)
      &.last&.check_out || (Time.current - rand(1..60).days)
    weeks_to_populate = ((Time.current - last_attendance_check_out).seconds.in_days / 7).round
    active_child_approval = child.active_child_approval(Time.current)

    weeks_to_populate.times do |week|
      puts "\n\nPopulating week #{week} for #{child.full_name}"
      rand(4..6).times do
        start_date = last_attendance_check_out + week.weeks
        check_in = Faker::Time.between(from: last_attendance_check_out, to: start_date.at_end_of_week(:saturday))
        break if check_in > Time.current

        check_out = check_in + rand(0..23).hours + rand(0..59).minutes
        Attendance.create!(check_in: check_in, check_out: check_out, child_approval: active_child_approval)
        last_attendance_check_out = child.attendances.presence&.order(check_in: :desc)
          &.last&.check_out || (Time.current - rand(1..60).days)
      end
    end
  end
end
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/AbcSize
