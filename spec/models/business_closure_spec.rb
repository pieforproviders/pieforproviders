# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BusinessClosure do
  it { is_expected.to belong_to(:business) }
end

# == Schema Information
#
# Table name: business_closures
#
#  id          :uuid             not null, primary key
#  date        :date
#  is_holiday  :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#
# Indexes
#
#  index_business_closures_on_business_id  (business_id)
#  unique_business_closure                 (business_id,date) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
