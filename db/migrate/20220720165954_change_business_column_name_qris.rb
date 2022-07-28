class ChangeBusinessColumnNameQris < ActiveRecord::Migration[6.1]
  def change
    rename_column :businesses, :qris_rating, :quality_rating
  end
end
