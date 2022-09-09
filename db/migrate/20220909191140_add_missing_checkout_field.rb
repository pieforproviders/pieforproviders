class AddMissingCheckoutField < ActiveRecord::Migration[6.1]
  def change
    add_column :service_days, :missing_checkout, :boolean, default: nil
  end
end
