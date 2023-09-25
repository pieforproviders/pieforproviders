class SetCurrentlyActiveTrueForChildBusiness < ActiveRecord::Migration[6.0] # Asegúrate de que coincida con la versión que estás utilizando
  def up
    ChildBusiness.update_all(currently_active: true)
  end

  def down
  end
end

