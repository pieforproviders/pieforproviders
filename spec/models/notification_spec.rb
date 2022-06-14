# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:child) }
  it { is_expected.to belong_to(:approval) }

  it 'validates the uniquness of approvals scoped to child' do
    notif = create(:notification)
    expect(notif).to validate_uniqueness_of(:approval).scoped_to(:child_id)
  end
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
