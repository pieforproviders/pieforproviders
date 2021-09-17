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

def now
  Time.current
end

def last_attendance_check_out
  active_child_approval
    .attendances
    .where('check_in <= ? and check_in >= ?', now.at_end_of_month, now.at_beginning_of_month)
    .order(check_in: :desc)&.first&.check_out || now.at_beginning_of_month
end

def active_child_approval
  @child.active_child_approval(now)
end

def current_approval_amounts
  if @child.state == 'NE'
    puts 'No attendance logic for Nebraska has been implemented'
  else
    active_child_approval.illinois_approval_amounts.find_by('month = ?', now.beginning_of_month)
  end
end

def weeks_to_populate
  # how many weeks have passed between now and the last check_out?
  ((now.yday - last_attendance_check_out.yday) / 7.0).floor
end

def part_day_attendances
  current_approval_amounts.part_days_approved_per_week * weeks_to_populate
end

def full_day_attendances
  current_approval_amounts.full_days_approved_per_week * weeks_to_populate
end

def add_attendance(type)
  check_in = Faker::Time.between(from: last_attendance_check_out, to: now)
  hours = type == 'part' ? 6 : 11
  check_out = check_in + hours.hours + rand(0..59).minutes
  active_child_approval.attendances << Attendance.new(check_in: check_in, check_out: check_out)
end

def types_array
  types = []
  rand(0..(part_day_attendances + 1)).times { types << 'part' }
  rand(0..(full_day_attendances + 1)).times { types << 'full' }
  types
end

def generate_attendances
  Child.all.each do |child|
    @child = child

    # if the child doesn't have an approval for this month or if we don't have any weeks to populate, skip this child
    next unless weeks_to_populate.positive? && current_approval_amounts

    types_array.shuffle.each do |type|
      # skip if the last attendance was today or in the future
      next if last_attendance_check_out.today? || last_attendance_check_out.future?

      add_attendance(type)
    end
  end
end
