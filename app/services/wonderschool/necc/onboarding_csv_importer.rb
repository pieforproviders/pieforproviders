# frozen_string_literal: true

module Wonderschool
  module Necc
    # Wonderschool NECC Onboarding CSV Importer
    class OnboardingCsvImporter < S3CsvImporter
      private

      def action
        'onboarding csv importer'
      end

      def source_bucket
        Rails.application.config.aws_necc_onboarding_bucket
      end

      def archive_bucket
        Rails.application.config.aws_necc_onboarding_archive_bucket
      end

      def process_row(row)
        @row = row
        build_case
        @business.update!(optional_business_params)
        @child_approval.update!(child_approval_params)
        approval_amount_params[:approval_periods].each { |period| NebraskaApprovalAmount.find_or_create_by!(nebraska_approval_amount_params(period)) }
      rescue StandardError => e
        send_error(e, @row['Case number']) # returns false
      end

      def build_case
        @business = Business.find_or_create_by!(required_business_params)
        @child = Child.find_or_initialize_by(child_params)
        approval = existing_or_new_approval
        @child.approvals.include?(approval) || @child.approvals << approval # idempotency - add only if it's not already associated
        @child.save!
        @child_approval = ChildApproval.find_by(child: @child, approval: approval)
      end

      def existing_or_new_approval
        Approval.includes(children: :business).where(children: { business: @business }).find_by(approval_params) || Approval.find_or_create_by!(approval_params)
      end

      def approval_params
        {
          case_number: @row['Case number'],
          effective_on: @row['Effective on'],
          expires_on: @row['Expires on']
        }
      end

      def required_business_params
        {
          user: User.find_by!(email: @row['Provider Email']&.downcase),
          name: @row['Provider Name'],
          zipcode: @row['Business Zip Code'],
          county: @row['Business County'],
          license_type: @row['Business License'].downcase.tr(' ', '_')
        }
      end

      def optional_business_params
        {
          qris_rating: @row['Business QRIS rating'],
          accredited: to_boolean(@row['Accredited'])
        }
      end

      def child_approval_params
        {
          full_days: to_integer(@row['Authorized full day units']),
          hours: to_float(@row['Authorized hourly units']),
          authorized_weekly_hours: to_float(@row['Authorized weekly hours']),
          special_needs_rate: to_boolean(@row['Special Needs Rate?']),
          special_needs_daily_rate: to_float(@row['Special Needs Daily Rate']),
          special_needs_hourly_rate: to_float(@row['Special Needs Hourly Rate'])
        }
      end

      def child_params
        {
          business_id: @business.id,
          full_name: @row['Full Name'],
          dhs_id: @row['Client ID'],
          date_of_birth: @row['Date of birth (required)'],
          enrolled_in_school: to_boolean(@row['Enrolled in School (Kindergarten or later)'])
        }
      end

      def approval_amount_params
        # NOTE: approvals attributes or anything else we decide to pass has to be added
        # *BEFORE* we run group_approval_periods because delete_if is destructive
        # but it's also the cleanest way to deal with removing unnecessary params
        # because once you start acting on a CSV::Row as a hash or array, the nesting
        # becomes challenging to work with
        { approvals_attributes: [approval_params] }.merge({ approval_periods: group_approval_periods })
      end

      def nebraska_approval_amount_params(approval_period)
        {
          child_approval: @child_approval,
          effective_on: approval_period[:effective_on],
          expires_on: approval_period[:expires_on],
          family_fee: approval_period[:family_fee],
          allocated_family_fee: approval_period[:allocated_family_fee]
        }
      end

      # groups the approval period fields by headers, i.e. "Approval #1 - Family Fee", "Approval #1 - Begin Date", etc.
      def group_approval_periods
        approval_fields = @row.delete_if { |header, field| !header.to_s.start_with?('Approval') || field.nil? }

        approval_fields.headers.map { |header| header.split(' - ')[0] }.uniq.map! do |approval_number|
          {
            effective_on: find_field(approval_number, 'Begin'),
            expires_on: find_field(approval_number, 'End'),
            family_fee: find_field(approval_number, 'Family Fee', 'Allocated'),
            allocated_family_fee: find_field(approval_number, 'Allocated')
          }
        end
      end

      def find_field(approval_number, include_key, exclude_key = nil)
        @row[@row.to_h.keys.find { |key| key.include?(approval_number) && key.include?(include_key) && (exclude_key.nil? || key.exclude?(exclude_key)) }]
      end
    end
  end
end
