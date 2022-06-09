# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: notifications
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  approval_id :uuid
#  child_id    :uuid
#
# Indexes
#
#  index_notifications_on_approval_id               (approval_id)
#  index_notifications_on_child_id                  (child_id)
#  index_notifications_on_child_id_and_approval_id  (child_id,approval_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#
