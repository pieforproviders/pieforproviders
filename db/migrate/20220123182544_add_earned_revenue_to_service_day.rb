class AddEarnedRevenueToServiceDay < ActiveRecord::Migration[6.1]
  def change
    add_monetize :service_days, :earned_revenue, amount: { null: true, default: nil }
    ServiceDay.all.in_batches.each_with_index do |sd_batch, batch_index|
      Rails.logger.info "Processing service day batch ##{batch_index}"
      sd_batch.map do |sd|
        EarnedRevenueCalculator.new(service_day: sd).call
      end
    end
  end
end
