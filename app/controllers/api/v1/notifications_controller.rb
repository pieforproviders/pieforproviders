# frozen_string_literal: true

module Api
	module V1
		class NotificationsController < Api::V1::ApiController
			before_action :set_notifications, only: %i[index]

			def index
				notifications_list = []
				@notifications.each do |notification|
					notify = NotificationBlueprint.render(notification)
					notifications << notify
				end
				render json: notifications
			end

			private

			def set_notifications
				@notifications = policy_scope(Notifications.includes(child: {business: :user}))
			end
		end
	end
end