class AddSlugs < ActiveRecord::Migration[6.0]
  def up
    User.all.each { |user| user.update!(slug: Digest::SHA1.hexdigest(user.email)[8..14]) }
    Business.all.each { |business| business.update!(slug: Digest::SHA1.hexdigest("#{business.name}#{business.category}")[8..14]) }
    Child.all.each { |child| child.update!(slug: Digest::SHA1.hexdigest("#{child.full_name}#{child.date_of_birth}")[8..14]) }
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
    puts "no down action on adding slugs to user, business, child"
  end
end
