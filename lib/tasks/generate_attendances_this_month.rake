# frozen_string_literal: true

# This is meant to simulate someone entering attendances during a month;
# it should work multiple times a month, and it should only generate
# attendances between the day it is run and the last attendance that was entered
desc 'Generate attendances this month'
task generate_attendances_this_month: :environment do
  return unless ENV.fetch('ALLOW_SEEDED_ATTENDANCES', 'false') == 'true'

  Child.all.each do |child|
    # get the current approval and the amounts for which the child is approved, for this month
    active_child_approval = child.active_child_approval(now)
    current_approval_amounts = active_child_approval.illinois_approval_amounts.find_by('month = ?', now.beginning_of_month)

    # if the child doesn't have an approval for this month, skip them
    next unless current_approval_amounts

    # if the last time we had an attendance for this child is today, skip them
    next if last_attendance_check_out(active_child_approval).today?

    # how many weeks have passed between now and the last check_out?
    # if the date today is week 1 of the year (i.e. the first full week in this year, sometime in the first 7 days of January),
    # or if the last attendance was this week, let's just generate 1 week's worth of attendances
    # otherwise, let's calculate the number of weeks between the last check_out and now
    weeks_to_populate = if now.cweek == 1 || now.cweek == last_attendance_check_out(active_child_approval).to_date.cweek
                          1
                        else
                          now.cweek - last_attendance_check_out(active_child_approval).to_date.cweek
                        end

    # if our last attendance is in the future, we have some bad data, so let's skip this kid
    next unless weeks_to_populate > 0

    # multiply the weeks we're generating attendances for by the number of attendances the child is approved for per week
    number_of_part_day_attendances_to_create = current_approval_amounts.part_days_approved_per_week * weeks_to_populate
    number_of_full_day_attendances_to_create = current_approval_amounts.full_days_approved_per_week * weeks_to_populate

    types = []

    # to introduce a little randomness, we're picking a random number between 0 and the number of attendances allowed plus 1
    # and generating that number of attendances
    rand(0..(number_of_part_day_attendances_to_create + 1)).times { types << 'part' }
    rand(0..(number_of_full_day_attendances_to_create + 1)).times { types << 'full' }

    # we're generating attendances shuffled so part-days and full-days are distributed
    # randomly
    types.shuffle.each do |type|
      # grab the next most recent attendance
      puts "Last attendance for #{child.full_name} was #{last_attendance_check_out(active_child_approval).strftime('%m/%d/%Y %l:%M %P')}"
      break if last_attendance_check_out(active_child_approval).today?

      check_in = Faker::Time.between(from: last_attendance_check_out(active_child_approval), to: now)
      hours = type == 'part' ? 6 : 11
      check_out = check_in + hours.hours + rand(0..59).minutes
      puts "Generating #{type} day attendance for #{child.full_name}, check_in: #{check_in.strftime('%m/%d/%Y %l:%M %P')}, check_out: #{check_out.strftime('%m/%d/%Y %l:%M %P')}"
      active_child_approval.attendances << Attendance.new(check_in: check_in, check_out: check_out)
      active_child_approval.reload
    end
  end
  # find attendances for this month, ordered in descending order by check_in time
  # if there are none, set the last checkout to the beginning of the month
end

def now
  DateTime.now
end

def last_attendance_check_out(_approval)
  active_child_approval.attendances.where('check_in < ? and check_in > ?', now, now.at_beginning_of_month).order(check_in: :desc)&.last&.check_out || now.at_beginning_of_month
end
