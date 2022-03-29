class AddIndexForChildNameAndBusiness < ActiveRecord::Migration[6.1]
  def change
    remove_index :children, %w[full_name date_of_birth business_id], name: 'unique_children', unique: true
    add_index :children,
              %w[first_name last_name date_of_birth business_id],
              name: 'unique_children',
              unique: true
  end
end
