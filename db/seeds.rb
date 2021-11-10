# frozen_string_literal: true

return unless Rails.application.config.allow_seeding

require 'faker'

# This seeds the db with data. It is not used in production.
# Use :find_or_create_by! or :first_or_create! when creating objects

ActionMailer::Base.perform_deliveries = false

Rails.logger.info 'Seeding.......'

THIS_YEAR = Time.current.year
JAN_1 = Date.new(THIS_YEAR, 1, 1)
MAR_31 = Date.new(THIS_YEAR, 3, 31)
APR_1 = Date.new(THIS_YEAR, 4, 1)
JUN_30 = Date.new(THIS_YEAR, 6, 30)

# minimum birthdates (ages)
MIN_BIRTHDAY = (Time.current - 2.weeks)
MAX_BIRTHDAY = (Time.current - 14.years)

# Use puts to show the number of records in the database for a given class
def puts_records_in_db(klass)
  puts " ... #{klass.count} #{klass.name.pluralize} now in the db"
end

# ---------------------------------------------
# Rates
# ---------------------------------------------

# currently active rule
IllinoisRate.first_or_create!(
  name: 'Rate 1',
  max_age: 18,
  license_type: Licenses::TYPES.sample,
  county: 'Cook',
  effective_on: Date.current - 4.years,
  full_day_rate: 29.5,
  part_day_rate: 15.4,
  attendance_threshold: 0.49
)

puts_records_in_db(IllinoisRate)

# ---------------------------------------------
# Users
# ---------------------------------------------

@user_admin = User.where(email: 'admin@test.com').first_or_create!(
  full_name: 'Admin User',
  greeting_name: 'Addie',
  language: 'es',
  opt_in_email: false,
  opt_in_text: false,
  organization: 'Pie for Providers',
  password: 'testpass1234!',
  password_confirmation: 'testpass1234!',
  service_agreement_accepted: true,
  timezone: 'Central Time (US & Canada)',
  admin: true
)

@user_kate = User.where(email: 'test@test.com').first_or_create(
  active: true,
  full_name: 'Kate Donaldson',
  greeting_name: 'Kate',
  language: 'en',
  opt_in_email: true,
  opt_in_text: true,
  organization: 'Pie for Providers',
  password: 'testpass1234!',
  password_confirmation: 'testpass1234!',
  phone_number: '8888888888',
  phone_type: 'cell',
  service_agreement_accepted: true,
  timezone: 'Central Time (US & Canada)'
)

@user_nebraska = User.where(email: 'nebraska@test.com').first_or_create(
  active: true,
  full_name: 'Nebraska Provider',
  greeting_name: 'Candice',
  language: 'en',
  opt_in_email: true,
  opt_in_text: true,
  organization: 'Nebraska Child Care',
  password: 'testpass1234!',
  password_confirmation: 'testpass1234!',
  service_agreement_accepted: true,
  timezone: 'Mountain Time (US & Canada)'
)

@user_admin.confirm
@user_kate.confirm
@user_nebraska.confirm

puts_records_in_db(User)

# ---------------------------------------------
# Businesses
# ---------------------------------------------

@business = Business.where(name: 'Happy Seedlings Childcare', user: @user_kate).first_or_create!(
  license_type: Licenses::TYPES.sample,
  county: 'Cook',
  zipcode: '60606'
)

@business_nebraska = Business.where(name: 'Nebraska Home Child Care', user: @user_nebraska).first_or_create!(
  license_type: Licenses::TYPES.sample,
  county: 'Cook',
  zipcode: '68123'
)

puts_records_in_db(Business)

# ---------------------------------------------
# Children w/ Required Approvals
# ---------------------------------------------

# find_or_create_by! a Child with the full_name,
#  and birthday set randomly between the min_age and max_age.
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/ParameterLists
def create_case(full_name,
                business: @business,
                case_number: Faker::Number.number(digits: 10),
                effective_on: Faker::Date.between(from: 11.months.ago, to: 2.months.ago),
                date_of_birth: Faker::Date.between(from: MAX_BIRTHDAY, to: MIN_BIRTHDAY),
                copay: Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000),
                add_expired_approval: false)

  frequency = copay ? Approval::COPAY_FREQUENCIES.sample : nil

  approvals = [
    Approval.find_or_create_by!(
      case_number: case_number,
      copay_cents: copay,
      copay_frequency: frequency,
      effective_on: effective_on,
      expires_on: nil
    )
  ]

  if add_expired_approval
    approvals << Approval.find_or_create_by!(
      case_number: case_number,
      copay_cents: copay ? copay - 1200 : nil,
      copay_frequency: frequency,
      effective_on: effective_on - 1.year,
      expires_on: nil
    )
  end

  child = Child.find_or_initialize_by(business: business,
                                      wonderschool_id: business == @business_nebraska ? Faker::Name.wonderschool_id.to_i : nil,
                                      full_name: full_name,
                                      date_of_birth: date_of_birth)
  child.approvals << approvals
  child.save!

  case child.state
  when 'IL'
    12.times do |idx|
      IllinoisApprovalAmount.create!(
        child_approval: child.active_child_approval(Time.current),
        month: Time.current.at_beginning_of_month + idx.months,
        part_days_approved_per_week: rand(0..3),
        full_days_approved_per_week: rand(0..2)
      )
    end
  when 'NE'
    total_absences = rand(0..10).round
    total_days = rand(0..25).round
    total_hours = rand(0.0..10.0).round

    child.approvals.each do |approval|
      special_needs_rate = Faker::Boolean.boolean
      ChildApproval.find_by(child: child, approval: approval).update!(
        full_days: rand(0..30),
        hours: rand(0..120),
        special_needs_rate: special_needs_rate,
        special_needs_daily_rate: special_needs_rate ? rand(0.0..20).round(2) : nil,
        special_needs_hourly_rate: special_needs_rate ? rand(0.0..10).round(2) : nil,
        enrolled_in_school: Faker::Boolean.boolean,
        authorized_weekly_hours: rand(0..45)
      )
    end

    effective_on = Faker::Date.between(from: 8.months.ago, to: 4.months.ago)

    5.times do |idx|
      Schedule.find_or_initialize_by(child: child).update!(
        effective_on: effective_on,
        duration: rand(0..23).hours.in_seconds,
        weekday: idx + 1
      )
    end

    TemporaryNebraskaDashboardCase.find_or_initialize_by(child: child).update!(
      attendance_risk: %w[on_track exceeded_limit at_risk].sample,
      absences: "#{rand(0..total_absences)} of #{total_absences}",
      earned_revenue: rand(0.00..1000.00).round(2),
      estimated_revenue: rand(1000.00..2000.00).round(2),
      family_fee: rand(1000.00..2000.00).round(2),
      full_days: rand(0..total_days),
      hours: rand(0.0..total_hours).round(2),
      hours_attended: "#{rand(0.0..total_hours).round(2)} of #{total_hours}"
    )
  end
end
# rubocop:enable Metrics/ParameterLists
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/AbcSize

create_case('Maria Baca')
create_case('Adédèjì Adébísí', case_number: '1234567A')
create_case('Atinuke Adébísí', case_number: '1234567A', add_expired_approval: true)
create_case("K'Shawn Henderson")
create_case('Marcus Smith')
create_case('Sabina Akers', add_expired_approval: true)
create_case('Mubiru Karstensen')
create_case('Tarquinius Kelly', add_expired_approval: true)
create_case('Rhonan Shaw', business: @business_nebraska)
create_case('Tanim Zaidi', business: @business_nebraska, add_expired_approval: true)
create_case('Jasveen Khirwar', business: @business_nebraska, add_expired_approval: true)
create_case('Manuel Céspedes', business: @business_nebraska)

puts_records_in_db(Child)

Rake::Task['nebraska:rates'].invoke

Rails.logger.info 'Seeding is done!'
