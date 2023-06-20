FactoryBot.define do
  factory :state do
    name { "MyString" }
    code { "MyString" }
    subsidy_type { "MyString" }
  end
end

# == Schema Information
#
# Table name: states
#
#  id           :uuid             not null, primary key
#  code         :string
#  name         :string
#  subsidy_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
