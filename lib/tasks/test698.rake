# frozen_string_literal: true

namespace :test698 do
  task kids_and_schedules: :environment do
    if Rails.application.config.allow_seeding
      children = Child.joins(:business).where(business: { state: 'NE' }).take(2)
      return unless children

      children.map do |child|
        child.update(active: true)
        child.schedules.destroy_all
        child.attendances.destroy_all
      end

      Schedule.create!(child: children.first, weekday: 1, start_time: '8:00AM', end_time: '3:00PM', effective_on: 'June 1, 2021')

      children.map do |child|
        child.reload
        active_child_approval = child.active_child_approval(Time.current)
        next unless child && active_child_approval

        puts "\n\n\n\nChild: #{child.full_name} should have an entry for the number of days in their schedule (1)'}\n\n\n\n"

        Attendance.create!(child_approval: active_child_approval, check_in: DateTime.new(2021, 7, 3, 7, 0, 0), check_out: nil)
      end

    else
      puts 'Error seeding attendances: this environment does not allow for seeding attendances'
    end
  end
end
