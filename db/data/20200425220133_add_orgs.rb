class AddOrgs < ActiveRecord::Migration[6.0]
  def up
    User.all.each { |user| user.update!(organization: "temp") }
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
    puts "no down action on adding organizationss to user"
  end
end
