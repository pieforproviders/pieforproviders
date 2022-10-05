# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# Illinois Onboarding CSV Importer
class IllinoisOnboardingCaseImporter
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
    process_onboarding_cases
  end

  private

  def retrieve_file_names
    @client.list_file_names(@source_bucket, 'IL/').select { |s| s.ends_with? '.csv' }
  end

  def process_onboarding_cases
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
      action: 'onboarding-case-importer',
      exception: e,
      tags: { source_bucket: @source_bucket }
    )
  end

  def process_row(row)
    @row = row
    @business = Business.find_or_create_by!(required_business_params)
    @child = Child.find_or_initialize_by(required_child_params)
    @approval = find_approval

    raise NotEnoughInfo, @child.errors unless @child.valid?

    build_case
  rescue StandardError => e
    send_appsignal_error(
      action: 'onboarding-case-importer',
      exception: e,
      tags: { case_number: @row['Case number'] }
    )
  end

  def find_approval
    @child.approvals << Approval.find_or_create_by!(approval_params) unless @child.approvals.find_by(approval_params)
    @child.save
    @child.approvals.find_by(approval_params)
  end

  def update_overlapping_approvals
    return unless @child.approvals&.length&.> 1

    overlapping_approvals.presence&.map { |oa| oa.update!(expires_on: approval_params[:effective_on] - 1.day) }
  end

  def approvals_to_update
    @child.approvals.reject { |app| app == @child.approvals.find_by(approval_params) }
  end

  def overlapping_approvals
    date = approval_params[:effective_on]
    approvals_to_update.select { |approval| date.between?(approval.effective_on, approval.expires_on) }
  end

  def build_case
    @child.update!(optional_child_params)
    @business.update!(optional_business_params)
    update_overlapping_approvals
    @child_approval = @child.reload.child_approvals.find_by(approval: @approval)
    update_child_approval
    update_illinois_approval_amounts
  end

  def update_child_approval
    @child_approval&.update!(child_approval_params)
  end

  def update_existing_amount(month)
    IllinoisApprovalAmount.find_by(
      month: month,
      child_approval: @child_approval
    )&.update!(
      part_days_approved_per_week: illinois_params[:part_days_approved_per_week],
      full_days_approved_per_week: illinois_params[:full_days_approved_per_week]
    )
  end

  def update_illinois_amounts_for_period(period)
    months(period).each do |month|
      next if update_existing_amount(month)

      IllinoisApprovalAmount.create!(
        month: month,
        child_approval: @child_approval,
        part_days_approved_per_week: illinois_params[:part_days_approved_per_week],
        full_days_approved_per_week: illinois_params[:full_days_approved_per_week]
      )
    end
  end

  def update_illinois_approval_amounts
    approval_amount_params[:approval_periods].each do |period|
      approval = @child.approvals.find_by(approval_params)
      next unless period[:effective_on]&.between?(approval.effective_on, approval.expires_on)

      update_illinois_amounts_for_period(period)
    end
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
      license_type: @row['Business License'].downcase.tr(' -', '_')
    }
  end

  def optional_business_params
    {
      quality_rating: to_quality_rating(@row['Business QRIS rating']),
      accredited: to_boolean(@row['Accredited'])
    }
  end

  # TODO: this is a really bad implementation
  # but we're going to be refactoring QRIS to a table
  # soon so I'm going to leave it
  def to_quality_rating(value)
    ratings = {
      'not rated' => 'not_rated',
      'Step 1' => 'step_one',
      'Step 2' => 'step_two',
      'Step 3' => 'step_three',
      'Step 4' => 'step_four',
      'Step 5' => 'step_five'
    }
    ratings[value]
  end

  def child_approval_params
    {
      full_days: to_integer(@row['Authorized full day units']),
      hours: to_float(@row['Authorized hourly units']),
      authorized_weekly_hours: to_float(@row['Authorized weekly hours']),
      special_needs_rate: to_boolean(@row['Special Needs Rate?']),
      special_needs_daily_rate: to_float(@row['Special Needs Daily Rate']),
      special_needs_hourly_rate: to_float(@row['Special Needs Hourly Rate']),
      enrolled_in_school: to_boolean(@row['Enrolled in School (Kindergarten or later)'])
    }
  end

  def illinois_params
    {
      part_days_approved_per_week: @row['part_days_approved_per_week'],
      full_days_approved_per_week: @row['full_days_approved_per_week']
    }
  end

  def required_child_params
    {
      business_id: @business.id,
      first_name: @row['First Name'],
      last_name: @row['Last Name'],
      dhs_id: @row['Client ID'],
      date_of_birth: @row['Date of birth (required)']
    }
  end

  def optional_child_params
    {
      wonderschool_id: @row['Wonderschool ID']
    }
  end

  def approval_amount_params
    { approvals_attributes: [approval_params] }.merge({ approval_periods: group_approval_periods })
  end

  # groups the approval period fields by headers, i.e. "Approval #1 - Family Fee", "Approval #1 - Begin Date", etc.
  def group_approval_periods
    @approval_fields = CSV::Row.new(@row.headers, @row.fields)
    @approval_fields.delete_if { |header, field| !header.to_s.start_with?('Approval') || field.nil? }
    map_approval_fields
  end

  def map_approval_fields
    @approval_fields.headers.map { |header| header.split(' - ')[0] }.uniq.map! do |approval_number|
      {
        effective_on: find_field(approval_number, 'Begin'),
        expires_on: find_field(approval_number, 'End'),
        family_fee: find_field(approval_number, 'Family Fee', 'Allocated').to_s.gsub(/[^\d.]/, '').to_f
      }
    end
  end

  def find_field(approval_number, include_key, exclude_key = nil)
    @approval_fields[@approval_fields.to_h.keys.find do |key|
      key.include?(approval_number) && key.include?(include_key) && (exclude_key.nil? || key.exclude?(exclude_key))
    end ]
  end

  def months(period)
    (period[:effective_on].to_date.beginning_of_month..period[:expires_on].to_date).select { |d| d.day == 1 }
  end
end
# rubocop:enable Metrics/ClassLength
