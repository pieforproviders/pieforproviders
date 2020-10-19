class AddBusinessToChildren < ActiveRecord::Migration[6.0]
  def up
    Child.all.map { |child| child.update!(business: child.user.businesses.first) }
  end

  def down
    Child.all.map { |child| child.update!(user: child.business.user) }
  end
end
