class AddFieldsForNebraska < ActiveRecord::Migration[6.1]
  def change
    add_column :businesses, :qris_rating, :string
    add_column :businesses, :accredited, :boolean
    add_column :children, :dhs_id, :string
    add_column :children, :enrolled_in_school, :boolean
    add_column :child_approvals, :full_days, :integer
    add_column :child_approvals, :hours, :decimal
    add_column :child_approvals, :special_needs_rate, :boolean
    add_column :child_approvals, :special_needs_daily_rate, :decimal
    add_column :child_approvals, :special_needs_hourly_rate, :decimal
    add_column :child_approvals, :enrolled_in_school, :boolean

    create_table :nebraska_approval_amounts, id: :uuid do |t|
      t.references :child_approval, type: :uuid, null: false, foreign_key: true, index: true
      t.date :effective_on, null: false
      t.date :expires_on, null: false
      t.decimal :family_fee, null: false
      t.decimal :allocated_family_fee, null: false

      t.timestamps
    end
  end
end
