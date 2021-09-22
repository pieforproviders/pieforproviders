class RemoveDefaultFromIllinoisRate < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:illinois_rates, :effective_on, nil )
  end
end
