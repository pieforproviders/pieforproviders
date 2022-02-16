class RemoveEnrolledInSchoolFromChildren < ActiveRecord::Migration[6.1]
  def up
    Child.all.each do |c|
      c.child_approvals.update_all(enrolled_in_school: c.enrolled_in_school) if c.child_approvals.any?
    end
    remove_column :children, :enrolled_in_school
  end

  def down 
    add_column :children, :enrolled_in_school, :boolean
  end
end
