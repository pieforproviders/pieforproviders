# frozen_string_literal: true

class NotificationGenerator
	attr_reader :child, :date

	def initialize(child_id:, approval_id:)
		@child_id = child_id
		@approval_id = approval_id
	end

	def call
		generate_notification
	end

	private

	def generate_notification
		ActiveRecord::Base.transaction do
			Notification.create(approval_id: @approval_id, child_id: @child_id)
		end
	end
end