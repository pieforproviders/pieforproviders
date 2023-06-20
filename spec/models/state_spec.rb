require 'rails_helper'

RSpec.describe State, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
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
