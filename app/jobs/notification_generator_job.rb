# frozen_string_literal: true

class NotificationGeneratorJob < ApplicationJob
	def perform(approval:)
		return unless approval
		approval.child_approvals.each do |child_approval|
			NotificationGenerator.new(child_id: child_approval.child_id, approval_id: approval.id).call
		end
	end
end