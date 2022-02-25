# frozen_string_literal: true

# Service to seed demo attendances
class DemoAttendanceSeeder
  include AppsignalReporting

  def call
    generate_attendances
  rescue StandardError => e
    send_appsignal_error('seeding attendances', e)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def generate_attendances
    Child.all.each do |child|
      starting_date = (last_attendance_check_out(child: child) + 1.week).at_beginning_of_week(:sunday)
      weeks_to_populate = ((Time.current - starting_date).seconds.in_days / 7).round

      Rails.logger.info { "\nChild: #{child.full_name}" }
      Rails.logger.info { "Starting date: #{starting_date}" }
      Rails.logger.info { "Weeks to populate: #{weeks_to_populate}\n\n" }

      if weeks_to_populate.positive?
        create_attendances(
          child: child,
          weeks_to_populate: weeks_to_populate,
          starting_date: starting_date
        )
      end

      Rails.logger.info "\n===============\n"
    end
  end

  def create_attendances(child:, weeks_to_populate:, starting_date:)
    catch(:stop_making_attendances) do
      weeks_to_populate.times do |week|
        Rails.logger.info { "Week #{week + 1} attendances:" }
        week_start = starting_date + week.weeks
        week_end = week_start.at_end_of_week(:sunday)
        rand(4..6).times do |num|
          last_attendance = num.zero? ? week_start : last_attendance_check_out(child: child)
          break if last_attendance > week_end

          check_in = Faker::Time.between(from: last_attendance, to: week_end)
          Rails.logger.info range_string(num: num,
                                         last_attendance: last_attendance,
                                         week_end: week_end,
                                         check_in: check_in)
          active_child_approval = child.active_child_approval(check_in)
          if check_in > Time.current || !active_child_approval
            generate_messages(check_in: check_in, active_child_approval: active_child_approval)
            throw :stop_making_attendances
          end

          check_out = check_in + rand(0..23).hours + rand(0..59).minutes
          attendance = Attendance.create!(check_in: check_in,
                                          check_out: check_out,
                                          child_approval: active_child_approval)
          Rails.logger.info ' ...success' if attendance
        end
        Rails.logger.info "\n"
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
    Rails.logger.info ' ...fail, skipping more attendances'
    Rails.logger.info { "check_in after current time: #{check_in}" } if check_in > Time.current
    Rails.logger.info { "no active_child_approval for #{check_in}" } unless active_child_approval
  end

  def range_string(num:, last_attendance:, week_end:, check_in:)
    <<~STRING.squish
      #{num + 1} |
      Range: #{last_attendance.strftime('%Y-%m-%d %I:%M%P')} - #{week_end.strftime('%Y-%m-%d %I:%M%P')} |
      Check-In: #{check_in.strftime('%Y-%m-%d %I:%M%P')} |
    STRING
  end
  # rubocop:enable Metrics/AbcSize
end
