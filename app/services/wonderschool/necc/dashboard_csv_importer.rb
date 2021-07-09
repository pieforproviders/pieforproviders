# frozen_string_literal: true

module Wonderschool
  module Necc
    # Wonderschool NECC Dashboard CSV Importer
    class DashboardCsvImporter < S3CsvImporter
      private

      def action
        'dashboard csv importer'
      end

      def source_bucket
        Rails.application.config.aws_necc_dashboard_bucket
      end

      def archive_bucket
        Rails.application.config.aws_necc_dashboard_archive_bucket
      end

      def process_row(row)
        child = Child.find_by!(full_name: row['Child Name'], business: Business.find_by!(name: row['Business']))

        dashboard_case = TemporaryNebraskaDashboardCase.find_or_initialize_by(child: child)
        dashboard_case.update!(dashboard_params(row))
      rescue StandardError => e
        send_error(e) # returns false
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
