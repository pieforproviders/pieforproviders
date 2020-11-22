# frozen_string_literal: true

require 'faker'

# minimum birthdates (ages)

desc 'Add second user cases'
task dashboard_data: :environment do
  @min_birthday = (Time.zone.now - 2.weeks)
  @max_birthday = (Time.zone.now - 14.years)

  ActionMailer::Base.perform_deliveries = false

  # Create an new non-admin user
  @non_admin = User.where(email: 'second_user@test.com').first_or_create!(
    active: true,
    full_name: 'Second User',
    greeting_name: 'Seco',
    language: 'spanish',
    opt_in_email: true,
    opt_in_text: true,
    organization: 'Montana Child Care Alliance',
    password: 'testpass1234!',
    password_confirmation: 'testpass1234!',
    phone_number: '7777777777',
    phone_type: 'cell',
    service_agreement_accepted: true,
    timezone: 'Mountain Time (US & Canada)'
  )

  @non_admin.confirm

  @business = Business.where(name: 'Second Childcare', user: @non_admin).first_or_create!(
    license_type: Licenses.types.keys.sample,
    county: 'Big Horn',
    zipcode: '01246'
  )

  @case_number = Random.rand(10) > 7 ? nil : Faker::IDNumber.invalid
  @copay_cents = Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000)
  @effective_on = Faker::Date.between(from: 1.year.ago, to: Time.zone.today)
  @expires_on = @effective_on + 1.year - 1.day

  def random_copay_frequency(copay_frequency)
    copay_frequency || @copay_cents ? Approval::COPAY_FREQUENCIES.sample : nil
  end

  def create_current_approval(copay_frequency)
    Approval.find_or_create_by!(
      case_number: @case_number,
      copay_cents: @copay_cents,
      copay_frequency: random_copay_frequency(copay_frequency),
      effective_on: @effective_on,
      expires_on: @expires_on
    )
  end

  def create_expired_approval(copay_frequency)
    Approval.find_or_create_by!(
      case_number: @case_number,
      copay_cents: @copay_cents ? @copay_cents - 1200 : nil,
      copay_frequency: random_copay_frequency(copay_frequency),
      effective_on: @effective_on - 1.year,
      expires_on: @effective_on - 1.day
    )
  end

  def create_approvals(
    copay_frequency: nil,
    add_expired_approval: false
  )
    approvals = [create_current_approval(copay_frequency)]
    approvals << create_expired_approval(copay_frequency) if add_expired_approval
    approvals
  end

  def create_case(full_name, approvals)
    date_of_birth = Faker::Date.between(from: @max_birthday, to: @min_birthday)
    Child.find_or_create_by!(
      business: @business,
      full_name: full_name,
      date_of_birth: date_of_birth,
      approvals: approvals
    )
  end

  5.times do
    approvals = create_approvals(add_expired_approval: Random.rand(10) > 7)
    create_case(Faker::GreekPhilosophers.name, approvals)
  end
end
