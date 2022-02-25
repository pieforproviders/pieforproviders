# frozen_string_literal: true

require 'appsignal'

# This is meant to simulate someone entering attendances during a month;
# it should work multiple times a month, and it should only generate
# attendances between the day it is run and the last attendance that was entered
desc 'Generate attendances this month'
task attendances: :environment do
  if Rails.application.config.allow_seeding
    begin
      generate_attendances
    rescue StandardError => e
      send_appsignal_error('seeding attendances', e)
    end
  else
    puts 'Error seeding attendances: this environment does not allow for seeding attendances'
  end
end

# rubocop:disable Metrics/AbcSize
def generate_attendances
  Child.all.each do |child|
    starting_date = (last_attendance_check_out(child: child) + 1.week).at_beginning_of_week(:sunday)
    weeks_to_populate = ((Time.current - starting_date).seconds.in_days / 7).round

    puts "\nChild: #{child.full_name}"
    puts "Starting date: #{starting_date}"
    puts "Weeks to populate: #{weeks_to_populate}\n"

    if weeks_to_populate.positive?
      create_attendances(
        child: child,
        weeks_to_populate: weeks_to_populate,
        starting_date: starting_date
      )
    end

    puts "\n===============\n"
  end
end

def create_attendances(child:, weeks_to_populate:, starting_date:)
  catch(:stop_making_attendances) do
    weeks_to_populate.times do |week|
      puts "Week #{week + 1} attendances:"
      week_start = starting_date + week.weeks
      week_end = week_start.at_end_of_week(:sunday)
      rand(4..6).times do |num|
        last_attendance = num.zero? ? week_start : last_attendance_check_out(child: child)
        break if last_attendance > week_end

        check_in = Faker::Time.between(from: last_attendance, to: week_end)
        print range_string(num: num, last_attendance: last_attendance, week_end: week_end, check_in: check_in)
        active_child_approval = child.active_child_approval(check_in)
        if check_in > Time.current || !active_child_approval
          generate_messages(check_in: check_in, active_child_approval: active_child_approval)
          throw :stop_making_attendances
        end

        check_out = check_in + rand(0..23).hours + rand(0..59).minutes
        attendance = Attendance.create!(check_in: check_in, check_out: check_out, child_approval: active_child_approval)
        puts ' ...success' if attendance
      end
      puts "\n"
    end
  end
end

def last_attendance_check_out(child:)
  child.reload
  last_attendance = child.attendances.presence&.order(check_in: :desc)&.first
  last_attendance&.check_out&.in_time_zone(child.timezone) ||
    (Time.current.in_time_zone(child.timezone) - rand(10..60).days)
end

def generate_messages(check_in:, active_child_approval:)
  puts ' ...fail, skipping more attendances'
  puts "check_in after current time: #{check_in}" if check_in > Time.current
  puts "no active_child_approval for #{check_in}" unless active_child_approval
end

def range_string(num:, last_attendance:, week_end:, check_in:)
  <<~STRING.squish
    #{num + 1} |
    Range: #{last_attendance.strftime('%Y-%m-%d %I:%M%P')} - #{week_end.strftime('%Y-%m-%d %I:%M%P')} |
    Check-In: #{check_in.strftime('%Y-%m-%d %I:%M%P')} |
  STRING
end

def send_appsignal_error(action, exception, identifier = nil)
  Appsignal.send_error(exception) do |transaction|
    transaction.set_action(action)
    transaction.params = { time: Time.current.to_s, identifier: identifier }
  end
end
# rubocop:enable Metrics/AbcSize
