# frozen_string_literal: true

desc 'Generate attendances this month'
task generate_attendances_this_month: :environment do
  now = DateTime.now

  days_left_in_month = now.at_end_of_month.day - now.day

  Child.all.each do |child|
    rand(0..days_left_in_month).times do
      last_check_out = child.current_child_approval.attendances&.last&.check_out || now.at_beginning_of_month
      check_in = Faker::Time.between(from: last_check_out, to: now)
      check_out = check_in + rand(0..23).hours + rand(0..59).minutes
      child.current_child_approval.attendances << Attendance.new(check_in: check_in, check_out: check_out)
    end
  end
end
