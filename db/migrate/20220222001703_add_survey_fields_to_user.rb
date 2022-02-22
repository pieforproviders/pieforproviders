class AddSurveyFieldsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :stressed_about_billing, :text
    add_column :users, :not_as_much_money, :text
    add_column :users, :too_much_time, :text
    add_column :users, :accept_more_subsidy_families, :text
    add_column :users, :get_from_pie, :text
  end
end
