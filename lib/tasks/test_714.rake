# frozen_string_literal: true

task test_714: :environment do
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
