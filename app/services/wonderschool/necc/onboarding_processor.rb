# frozen_string_literal: true

require 'csv'

module Wonderschool
  module Necc
    # processes Onboarding data compiled from Wonderschool, NECC and provider data
    # rubocop:disable Metrics/ClassLength
    class OnboardingProcessor
      def initialize(input)
        @input = input
        @storage_client = Aws::S3::Client.new(
          credentials: Aws::Credentials.new(akid, secret),
          region: region
        )
      end

      def call
        read_contents
      end

      private

      def read_contents
        contents = convert_by_type

        log('blank_contents', @input.to_s) and return false if contents.blank?

        failed_subsidy_cases = []
        contents.each { |subsidy_case| failed_subsidy_cases << subsidy_case unless process_onboarding_case(subsidy_case) }

        if failed_subsidy_cases.present?
          log('failed_subsidy_cases', failed_subsidy_cases.flatten.to_s)
          store('failed_subsidy_cases', failed_subsidy_cases.flatten.to_s)
          return false
        end
        contents.to_s
      end

      def convert_by_type
        if [String, StringIO].member?(@input.class)
          parse_string_to_csv
        elsif File.file?(@input.to_s)
          read_csv_file
        end
      end

      def log(type, message)
        case type
        when 'blank_contents'
          Rails.logger.tagged('NECC Onboarding file cannot be processed') { Rails.logger.error message }
        when 'failed_subsidy_cases'
          Rails.logger.tagged('NECC Onboarding cases failed to process') { Rails.logger.error message }
        end
      end

      def store(file_name, data)
        @storage_client.put_object({ bucket: archive_bucket, body: data, key: file_name })
      end

      def read_csv_file
        CSV.read(
          @input,
          headers: true,
          return_headers: false,
          skip_lines: /^(,*|\s*)$/,
          unconverted_fields: %i[child_id],
          converters: %i[date]
        )
      end

      def parse_string_to_csv
        CSV.parse(
          @input,
          headers: true,
          return_headers: false,
          skip_lines: /^(,*|\s*)$/,
          unconverted_fields: %i[child_id],
          converters: %i[date]
        )
      end

      def process_onboarding_case(subsidy_case)
        user = User.find_by(email: subsidy_case['Provider Email']&.downcase)
        return false unless user

        ActiveRecord::Base.transaction do
          make_associated_case_records(subsidy_case, user)
        end
      rescue ActiveRecord::RecordInvalid => e
        log('error processing', e.to_s)
        false
      end

      # rubocop:disable Metrics/AbcSize
      def make_associated_case_records(subsidy_case, user)
        business = Business.find_or_create_by!(business_params(subsidy_case, user))
        approval = Approval.find_or_create_by!(approval_params(subsidy_case))
        child = Child.find_or_initialize_by(child_params(subsidy_case, business))
        child.approvals.find_by(approval_params(subsidy_case)) || child.approvals << approval
        child.save!

        child.child_approvals.find_by(approval: approval).update!(child_approval_params(subsidy_case))
        NebraskaApprovalAmountGenerator.new(child, approval_amount_params(subsidy_case)).call
      end
      # rubocop:enable Metrics/AbcSize

      def approval_amount_params(params)
        # NOTE: approvals attributes or anything else we decide to pass has to be added
        # *BEFORE* we run group_approval_periods because delete_if is destructive
        # but it's also the cleanest way to deal with removing unnecessary params
        # because once you start acting on a CSV::Row as a hash or array, the nesting
        # becomes challenging to work with
        { approvals_attributes: [approval_params(params)] }.merge(
          { approval_periods: group_approval_periods(params) }
        )
      end

      def approval_params(subsidy_case)
        {
          case_number: subsidy_case['Case number'],
          effective_on: subsidy_case['Effective on'],
          expires_on: subsidy_case['Expires on']
        }
      end

      def business_params(subsidy_case, user)
        {
          user_id: user.id,
          name: subsidy_case['Provider Name'],
          zipcode: subsidy_case['Business Zip Code'],
          county: subsidy_case['Business County'],
          qris_rating: subsidy_case['Business QRIS rating'],
          license_type: subsidy_case['Business License'].downcase.tr(' ', '_'),
          accredited: to_boolean(subsidy_case['Accredited'])
        }
      end

      def child_params(subsidy_case, business)
        {
          business_id: business.id,
          full_name: subsidy_case['Full Name'],
          dhs_id: subsidy_case['Client ID'],
          date_of_birth: subsidy_case['Date of birth (required)'],
          enrolled_in_school: to_boolean(subsidy_case['Enrolled in School (Kindergarten or later)'])
        }
      end

      def child_approval_params(subsidy_case)
        {
          full_days: to_integer(subsidy_case['Authorized full day units']),
          hours: to_float(subsidy_case['Authorized hourly units']),
          special_needs_rate: to_boolean(subsidy_case['Special Needs Rate?']),
          special_needs_daily_rate: to_float(subsidy_case['Special Needs Daily Rate']),
          special_needs_hourly_rate: to_float(subsidy_case['Special Needs Hourly Rate'])
        }
      end

      def to_float(value)
        value&.delete(',')&.to_f
      end

      def to_integer(value)
        value&.delete(',')&.to_i
      end

      def to_boolean(value)
        value == 'Yes'
      end

      def group_approval_periods(row)
        approval_fields = row.delete_if { |header, field| !header.to_s.start_with?('Approval') || field.nil? }

        approval_headers(approval_fields).map! do |approval|
          {
            effective_on: find_field(approval_fields, approval, 'Begin'),
            expires_on: find_field(approval_fields, approval, 'End'),
            family_fee: find_field(approval_fields, approval, 'Family Fee', 'Allocated'),
            allocated_family_fee: find_field(approval_fields, approval, 'Allocated')
          }
        end
      end

      def find_field(csv_row, approval_number_string, key_string, exclude_key_string = nil)
        if exclude_key_string
          csv_row[csv_row.to_h.keys.find { |k| k.include?(approval_number_string) && k.include?(key_string) && k.exclude?(exclude_key_string) }]
        else
          csv_row[csv_row.to_h.keys.find { |k| k.include?(approval_number_string) && k.include?(key_string) }]
        end
      end

      def approval_headers(row)
        row.headers.map { |header| header.split(' - ')[0] }.uniq
      end

      def archive_bucket
        ENV.fetch('AWS_NECC_ONBOARDING_ARCHIVE_BUCKET', '')
      end

      def akid
        ENV.fetch('AWS_ACCESS_KEY_ID', '')
      end

      def secret
        ENV.fetch('AWS_SECRET_ACCESS_KEY', '')
      end

      def region
        ENV.fetch('AWS_REGION', '')
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
