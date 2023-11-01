# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildBusiness do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: child_businesses
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  business_id :uuid             not null
#  child_id    :uuid             not null
#
# Indexes
#
#  index_child_businesses_on_business_id  (business_id)
#  index_child_businesses_on_child_id     (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#  fk_rails_...  (child_id => children.id)
#
