# frozen_string_literal: true

task not_attending_period_uploader: :environment do
  NotAttendingPeriodUploader.new.call
  sleep 5
end
