# frozen_string_literal: true

# StateTimeRule model
class StateTimeRule < ApplicationRecord
  belongs_to :state
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
