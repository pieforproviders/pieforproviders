# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
# Fix all service_days where the date is not at the beginning of the day for the child
desc 'Cast all service_days to the beginning of the day'
task cast_service_days_to_beginning_of_day: :environment do
  ServiceDay.find_each do |service_day|
    service_day.update!(date: service_day.date.in_time_zone(service_day.child.timezone).at_beginning_of_day)
  end
end

# Move all absences to a single service day if there are duplicates
desc 'Remove duplicate service days'
task remove_duplicate_service_days: :environment do
  columns_that_make_record_distinct = %i[child_id date]
  distinct_ids = ServiceDay.select("MIN(concat(id, '')) as id").group(columns_that_make_record_distinct).map(&:id)
  duplicate_records = ServiceDay.where.not(id: distinct_ids)
  Rails.logger.info "Duplicate Records: #{duplicate_records.count}"
  duplicate_records.each do |service_day|
    new_service_day = ServiceDay
                      .where(
                        child_id: service_day.child_id,
                        date: service_day.date
                      )
                      .where.not(id: service_day.id).first
    Rails.logger.info "New ID: #{new_service_day.id}"
    service_day.attendances.update_all(service_day_id: new_service_day.id)
    new_service_day.update_column(:absence_type, nil)
    service_day.destroy if service_day.attendances.empty?
  end
end
# rubocop:enable Rails/SkipsModelValidations
