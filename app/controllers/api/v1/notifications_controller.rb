# frozen_string_literal: true

module Api
  module V1
    # API for notifications
    class NotificationsController < Api::V1::ApiController
      before_action :set_notification,  only: %i[update destroy]
      before_action :set_notifications, only: %i[index]

      def index
        render json: NotificationBlueprint.render(@notifications)
      end

      def update
        if @notification
          @notification.update(notification_params)
          render json: NotificationBlueprint.render(@notification)
        else
          render status: :not_found
        end
      end

      def destroy
        if @notification
          @notification.destroy
          render status: :no_content
        else
          render status: :not_found
        end
      end

      private

      def set_notification
        @notification = policy_scope(Notification).find(params[:id])
      end

      def set_notifications
        @notifications = policy_scope(Notification.includes(:child, :approval)).sort_by do |notif|
          notif.approval.expires_on
        end
      end

      def notification_params
        params.require(:notification).permit(:child_id, :approval_id, :created_at)
      end
    end
  end
end
