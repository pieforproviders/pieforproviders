class AddTotalTimeInCareToServiceDays < ActiveRecord::Migration[6.1]
  def change
    add_column :service_days, :total_time_in_care, :interval
    add_reference :service_days, :schedule, index: true
    ServiceDay.all.in_batches.each_with_index do |sd_batch, batch_index|
      Rails.logger.info "Processing service day batch ##{batch_index}"
      sd_batch.map do |sd|
        schedule = sd.child.schedules.active_on(sd.date).find_by(weekday: sd.date.wday)
        sd.update!(updated_at: Time.now, schedule: schedule)
      end
    end
  end
end
