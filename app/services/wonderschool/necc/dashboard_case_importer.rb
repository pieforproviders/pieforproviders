# frozen_string_literal: true

module Wonderschool
  module Necc
    # Wonderschool NECC Dashboard Case Importer
    class DashboardCaseImporter
      include AppsignalReporting
      def initialize
        @client = AwsClient.new
        @source_bucket = Rails.application.config.aws_necc_dashboard_bucket
        @archive_bucket = Rails.application.config.aws_necc_dashboard_archive_bucket
      end

      def call
        process_dashboard_cases
      end

      private

      def process_dashboard_cases
        file_names = @client.list_file_names(@source_bucket)
        contents = file_names.map { |file_name| @client.get_file_contents(@source_bucket, file_name) }
        contents.each do |body|
          parsed_csv = CsvParser.new(body).call
          parsed_csv.each { |row| process_row(row) }
        end
        file_names.each { |file_name| @client.archive_file(@source_bucket, @archive_bucket, file_name) }
      end

      def process_row(row)
        child = Child.find_by!(full_name: row['Child Name'], business: Business.find_by!(name: row['Business']))

        dashboard_case = TemporaryNebraskaDashboardCase.find_or_initialize_by(child: child)
        dashboard_case.update!(dashboard_params(row))
      rescue StandardError => e
        send_appsignal_error('dashboard-case-importer', e.message, row['Case Number']) # returns false
      end

      # rubocop:disable Metrics/MethodLength
      def dashboard_params(row)
        {
          as_of: row['As of Date'],
          attendance_risk: row['Status'],
          absences: row['Absences'],
          earned_revenue: row['Earned revenue'],
          estimated_revenue: row['Estimated Revenue'],
          family_fee: row['Family Fee'],
          full_days: row['Full Days'],
          hours: row['Hourly'],
          hours_attended: row['Hours Attended']
        }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
