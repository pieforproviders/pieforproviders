# frozen_string_literal: true

# Fixes missing absences on 11/2/2021
desc 'Fix missing absences on 11/2/2021'
namespace :nebraska do
  task fix_absences: :environment do
    empty_service_days = ServiceDay.where.missing(:attendances)
    Rails.logger.info(empty_service_days.length)
    empty_service_days.map(&:destroy)

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
