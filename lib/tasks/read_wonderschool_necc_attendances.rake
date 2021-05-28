# frozen_string_literal: true

task process_wonderschool_necc_attendances: :environment do
  attendances = S3Downloader.new(logger_tag, source_bucket, archive_bucket).call
  Wonderschool::Necc::AttendanceProcessor.new(attendances).call
  S3Archiver.new(attendances).call

  def logger_tag
    "Wonderschool NECC Attendances"
  end

  def source_bucket
    Rails.application.config.aws_necc_attendance_bucket
  end

  def archive_bucket
    Rails.application.config.aws_necc_attendance_archive_bucket
  end

  def processor
    Wonderschool:Necc::AttendanceProcessor
  end
end
