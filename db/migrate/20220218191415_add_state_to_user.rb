class AddStateToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :state, :string, null: true, limit: 2

    User.all.map do |user|
      user.state = user&.businesses&.first&.state
      user.save!
    end
  end
end
