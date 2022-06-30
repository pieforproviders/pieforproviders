# frozen_string_literal: true

# This fixes missing absences from a bug in our daily job
desc 'Generate attendances this month'
task fix_absences_2022_06_14: :environment do
  Child.all.each do |child|
    dates = '2022-06-13'.in_time_zone(child.timezone).to_date..Time.current.in_time_zone(child.timezone).to_date
    dates.each do |date|
      next if child.service_days.where(date: date.at_beginning_of_day..date.at_end_of_day).present?

      schedule_for_weekday = child.schedules.active_on(date).for_weekday(date.wday).first

      next unless schedule_for_weekday.present?

      ServiceDay.create!(
        child: child,
        date: date.in_time_zone(child.timezone).at_beginning_of_day,
        absence_type: 'absence',
        schedule: schedule_for_weekday
      )
    end
  end
end
