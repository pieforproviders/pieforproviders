class AddAbsenceToServiceDay < ActiveRecord::Migration[6.1]
  def change
    add_column :service_days, :absence_type, :string, null: true, default: nil
  end
end
