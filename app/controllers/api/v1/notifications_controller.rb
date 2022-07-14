# frozen_string_literal: true

module Api
  module V1
    # API for notifications
    class NotificationsController < Api::V1::ApiController
      before_action :set_notification,  only: %i[update destroy show]
      before_action :set_notifications, only: %i[index]
      before_action :set_child_and_approval,  only: %i[create]

      def create
        if @approval
          if check_approval_validity
            create_notif_with_valid_params
          else
            render status: :bad_request
          end
        else
          render status: :not_found
        end
      end

      def show
        if @notification
          render json: NotificationBlueprint.render(@notification)
        else
          render status: :not_found
        end
      end

      def index
        render json: NotificationBlueprint.render(@notifications)
      end

      def update
        if @notification
          if @notification.update(notification_params)
            render json: NotificationBlueprint.render(@notification)
          else
            render json: @notification.errors, status: :unprocessable_entity
          end
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

      def check_approval_validity
        return unless @approval.notifications.empty? && @approval.expires_on.between?(0.days.after, 30.days.after)

        @child.approvals.where(effective_on: @approval.expires_on..).empty?
      end

      def create_notif_with_valid_params
        @notification = Notification.create(approval_id: @approval.id, child_id: @child.id)
        if @notification.save
          render json: NotificationBlueprint.render(@notification)
        else
          render json: @notification.errors, status: :unprocessable_entity
        end
      end

      def set_notification
        @notification = policy_scope(Notification).find(params[:id])
      end

      def set_notifications
        @notifications = policy_scope(Notification.includes(:child, :approval)).sort_by do |notif|
          notif.approval.expires_on
        end
      end

      def set_child_and_approval
        @child = policy_scope(Child).find(notification_params[:child_id])
        @approval = @child&.approvals&.find(notification_params[:approval_id])
      end

      def notification_params
        params.require(:notification).permit(:child_id, :approval_id, :created_at)
      end
    end
  end
end
