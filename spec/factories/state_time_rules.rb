FactoryBot.define do
  factory :state_time_rule do
    name { "MyString" }
    state { nil }
    min_time { "2023-06-19 11:33:22" }
    max_time { "2023-06-19 11:33:22" }
  end
end

# == Schema Information
#
# Table name: state_time_rules
#
#  id         :uuid             not null, primary key
#  max_time   :integer
#  min_time   :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :uuid             not null
#
# Indexes
#
#  index_state_time_rules_on_state_id  (state_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_id => states.id)
#
