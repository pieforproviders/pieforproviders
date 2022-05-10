# frozen_string_literal: true

# Fixes missing absences
desc 'Fix missing absences for newly onboarded kids'
namespace :nebraska do
  task fix_absences: :environment do
    empty_service_days = ServiceDay.where.missing(:attendances)
    Rails.logger.info("Empty service days: #{empty_service_days.size}")
    empty_service_days.map do |service_day|
      service_day.schedule ? service_day.update!(absence_type: 'absence') : service_day.destroy!
    end

    children = Child.nebraska.includes(:approvals)

    children.each do |child|
      today = Time.current.in_time_zone(child.timezone)
      # generate prior absences
      child.approvals.each do |approval|
        (approval.effective_on..([approval.expires_on, today].min)).each do |date|
          Nebraska::AbsenceGenerator.new(child, date).call
        end
      end
    end
  end
end
