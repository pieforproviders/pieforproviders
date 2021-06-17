# frozen_string_literal: true

namespace :test714 do
  task feature_flag: :environment do
    if Rails.application.config.allow_seeding
      child = Child.where(active: true).joins(:business).find_by(business: { state: 'NE' })
      puts "Adding attendance for #{child.full_name}"
      active_child_approval = child.active_child_approval(Time.current)
      return unless child && active_child_approval

      child.temporary_nebraska_dashboard_case.update!(hours: '35')
      Attendance.create!(child_approval: active_child_approval, check_in: Time.current - 24.hours, check_out: Time.current - 20.hours)
    else
      puts 'Error seeding attendances: this environment does not allow for seeding attendances'
    end
  end

  task kids_and_schedules: :environment do
    if Rails.application.config.allow_seeding
      children = Child.joins(:business).where(business: { state: 'NE' }).take(2)
      return unless children

      children.map do |child|
        child.update(active: true)
        child.schedules.destroy_all
        child.attendances.destroy_all
      end

      Schedule.create!(child: children.first, weekday: 1, start_time: '8:00AM', end_time: '12:00PM', effective_on: 'June 1, 2021')

      children.map do |child|
        child.reload
        active_child_approval = child.active_child_approval(Time.current)
        next unless child && active_child_approval

        puts "\n\n\n\nChild: #{child.full_name} should have: #{child.schedules.empty? ? 'no hours' : 'an entry for the number of hours in their schedule (4)'}\n\n\n\n"

        Attendance.create!(child_approval: active_child_approval, check_in: DateTime.new(2021, 6, 3, 7, 0, 0), check_out: nil)
      end

    else
      puts 'Error seeding attendances: this environment does not allow for seeding attendances'
    end
  end
end
