class UpdateRateRecord2022 < ActiveRecord::Migration[6.1]
  def change
    add_column :nebraska_rates, :qris_rating, :string
    add_column :nebraska_rates, :use_qris_rating_to_determine_rate, :boolean, default: false
    NebraskaRate.reset_column_information
    NebraskaRate.update_all(use_qris_rating_to_determine_rate: false)
  end
end
