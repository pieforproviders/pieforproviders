class RemoveAllSlugs < ActiveRecord::Migration[6.0]
  def up
    remove_column :attendances, :slug
    remove_index :businesses, :slug
    remove_column :businesses, :slug
    remove_index :case_cycles, :slug
    remove_column :case_cycles, :slug
    remove_index :child_case_cycle_payments, :slug
    remove_column :child_case_cycle_payments, :slug
    remove_index :child_case_cycles, :slug
    remove_column :child_case_cycles, :slug
    remove_index :children, :slug
    remove_column :children, :slug
    remove_column :payments, :slug
    remove_column :sites, :slug
    remove_index :users, :slug
    remove_column :users, :slug
  end

  def down
    add_column :attendances, :slug, :string
    add_column :businesses, :slug, :string
    add_index :businesses, :slug
    add_column :case_cycles, :slug, :string
    add_index :case_cycles, :slug
    add_column :child_case_cycle_payments, :slug, :string
    add_index :child_case_cycle_payments, :slug
    add_column :child_case_cycles, :slug, :string
    add_index :child_case_cycles, :slug
    add_column :children, :slug, :string
    add_index :children, :slug
    add_column :payments, :slug, :string
    add_column :sites, :slug, :string
    add_column :users, :slug, :string
    add_index :users, :slug
    Attendance.update_all(slug: SecureRandom.hex)
    Business.update_all(slug: SecureRandom.hex)
    CaseCycle.update_all(slug: SecureRandom.hex)
    # ChildCaseCyclePayment.update_all(slug: SecureRandom.hex) - this class doesn't exist so this fails
    ChildCaseCycle.update_all(slug: SecureRandom.hex)
    Child.update_all(slug: SecureRandom.hex)
    # Payment.update_all(slug: SecureRandom.hex) - this class doesn't exist so this fails
    # Site.update_all(slug: SecureRandom.hex) - this class doesn't exist so this fails
    User.update_all(slug: SecureRandom.hex)
    change_column :attendances, :slug, :string, null: false
    change_column :businesses, :slug, :string, null: false
    change_column :case_cycles, :slug, :string, null: false
    change_column :child_case_cycle_payments, :slug, :string, null: false
    change_column :child_case_cycles, :slug, :string, null: false
    change_column :children, :slug, :string, null: false
    change_column :payments, :slug, :string, null: false
    change_column :sites, :slug, :string, null: false
    change_column :users, :slug, :string, null: false
  end
end
