# frozen_string_literal: true

# Self-Serve Attendance Importer
class AttendanceCsvImporter
  include AppsignalReporting
  include CsvTypecasting

  class NotEnoughInfo < StandardError; end

  def initialize
    @client = AwsClient.new
    @source_bucket = Rails.application.config.aws_necc_attendance_bucket
    @archive_bucket = Rails.application.config.aws_necc_attendance_archive_bucket
  end

  def call
    process_attendances
  end

  private

  def process_attendances
    file_names = @client.list_file_names(@source_bucket)
    contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
    contents.each_with_index do |body, index|
      parsed_csv = CsvParser.new(body).call
      parsed_csv.each { |row| process_row(row, file_names[index]) }
    end
    file_names.each do |file_name|
      @client.archive_file(@source_bucket, @archive_bucket, "#{Time.current}-#{file_name}")
    end
  end

  def process_row(row, file_name)
    business = Business.find_by(name: file_name.split('-').first)
    log_missing_business(file_name.split('-').first) and return unless business

    child = find_child(business, row)
    log_missing_child(business.id, row['check_in'], row['check_out'], row['absence']) and return unless child

    create_attendance(row, child)
  rescue StandardError => e
    send_appsignal_error('self-serve-attendance-csv-importer', e, child&.id)
  end

  def create_attendance(row, child)
    check_in = row['check_in'].in_time_zone(child.timezone)

    att = Attendance.find_or_create_by!(
      child_approval: child.active_child_approval(check_in),
      check_in: check_in,
      check_out: row['check_out']&.in_time_zone(child&.timezone),
      absence: row['absence']
    )

    att.service_day.update!(row['absence'])
  end

  def find_child(business, row)
    business.children.find_by(first_name: row['first_name'], last_name: row['last_name']) ||
      business.children.find_by(dhs_id: row['dhs_id'])
  end

  def log_missing_child(id, check_in, check_out, absence)
    Rails.logger.tagged('attendance import') do
      # rubocop:disable Layout/LineLength
      message = "Business: #{id} - child record for attendance not found (check_in: #{check_in}, check_out: #{check_out}, absence: #{absence}); skipping"
      # rubocop:enable Layout/LineLength
      Rails.logger.info message
    end
  end

  def log_missing_business(name)
    Rails.logger.tagged('attendance import') do
      Rails.logger.info "Business #{name} not found; skipping"
    end
  end
end
