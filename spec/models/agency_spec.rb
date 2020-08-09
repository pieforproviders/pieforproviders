# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Agency, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:state) }
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
