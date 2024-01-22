# frozen_string_literal: true

# State Model
class State < ApplicationRecord
  has_one :state_time_rule, dependent: :destroy
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
