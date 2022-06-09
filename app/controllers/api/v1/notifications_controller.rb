# frozen_string_literal: true

module Api
  module V1
    # API for notifications
    class NotificationsController < Api::V1::ApiController
      before_action :set_notifications, only: %i[index]

      def index
        render json: NotificationBlueprint.render(@notifications)
      end

      private

      def set_notifications
        @notifications = policy_scope(Notification.includes(:child, :approval)).sort_by do |notif|
          notif.approval.expires_on
        end
      end
    end
  end
end
