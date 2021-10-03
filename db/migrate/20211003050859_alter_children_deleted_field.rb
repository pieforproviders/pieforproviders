class AlterChildrenDeletedField < ActiveRecord::Migration[6.1]
  def change
    add_column :children, :deleted_at, :date
    Child.where(deleted: true).each { |child| child.update_column(deleted_at: Date.today) }
    remove_column :children, :deleted
  end
end
