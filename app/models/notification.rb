class Notification < ApplicationRecord
	belongs_to :child 
	belongs_to :approval
	validates_uniqueness_of :approval_id, scope: :child_id
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
#  index_notifications_on_approval_id  (approval_id)
#  index_notifications_on_child_id     (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#
