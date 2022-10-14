# frozen_string_literal: true

module Illinois
  # Illinois Onboarding CSV Importer
  class IllinoisSchedulesImporter
    include AppsignalReporting
    include CsvTypecasting

    class NotEnoughInfo < StandardError; end
    class NoFilesFound < StandardError; end

    def initialize
      @client = AwsClient.new
      @source_bucket = Rails.application.config.aws_onboarding_bucket
      @archive_bucket = Rails.application.config.aws_onboarding_archive_bucket
    end

    def call
      process_schedules
    end

    private

    def retrieve_file_names
      @client.list_file_names(@source_bucket, 'IL/schedules/').select { |s| s.ends_with? '.csv' }
    end

    def process_schedules
      file_names = retrieve_file_names
      raise NoFilesFound, @source_bucket unless file_names

      contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
      contents.each do |body|
        parsed_csv = CsvParser.new(body).call
        parsed_csv.each { |row| process_row(row) }
      end
      file_names.each { |file_name| @client.archive_file(@source_bucket, @archive_bucket, file_name) }
    rescue StandardError => e
      send_appsignal_error(
        action: 'illinois-schedule-importer',
        exception: e,
        tags: { source_bucket: @source_bucket }
      )
    end

    def process_row(row)
      @row = row
      @business = Business.find_by(name: row['Provider Name'])
      @business.business_schedules.destroy_all if @business.business_schedules.count == 7
      build_schedule
      @business.save
    rescue StandardError => e
      send_appsignal_error(
        action: 'illinois-schedule-importer',
        exception: e,
        tags: { provider: @row['Provider Name'] }
      )
    end

    def build_schedule
      @business.business_schedules.build(required_schedule_params)
    end

    def required_schedule_params
      {
        weekday: @row['Weekday'].to_i,
        is_open: @row['Open'] == 'Yes'
      }
    end
  end
end
