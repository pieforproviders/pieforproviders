class SetCurrentlyActiveTrueForChildBusiness < ActiveRecord::Migration[6.0] 
  def up
    ChildBusiness.update_all(currently_active: true)
  end

  def down
  end
end

