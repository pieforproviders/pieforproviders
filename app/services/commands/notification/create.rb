# frozen_string_literal: true

module Commands
  module Notification
    # Command Pattern to create a notification
    class Create
      def initialize(child:, approval:)
        @child = child
        @approval = approval
      end

      def create
        return unless @approval.notifications.empty? && @approval.expires_on.between?(0.days.after, 30.days.after)
        return if @child.approvals.where(effective_on: @approval.expires_on..).presence

        ActiveRecord::Base.transaction do
          ::Notification.create(approval_id: @approval.id, child_id: @child.id)
        end
      end
    end
  end
end
