# frozen_string_literal: true

# Job to generate notifications, intended to be run daily
class NotificationGeneratorJob < ApplicationJob
  def perform
    NotificationGenerator.new.call
  end
end
