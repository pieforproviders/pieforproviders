# frozen_string_literal: true

# Agencies provide child care subsidy payments
#  Note that this class is 'read only' for client apps.
#  Data required for Agencies will be added to the db via rake tasks or other external means.
class Agency < UuidApplicationRecord
  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true
  validates :state, presence: true
end

# == Schema Information
#
# Table name: agencies
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  name       :string           not null
#  state      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_agencies_on_name_and_state  (name,state) UNIQUE
#
