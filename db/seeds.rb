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
MIN_BIRTHDAY = 2.weeks.ago
MAX_BIRTHDAY = 14.years.ago

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
  phone_number: '888-777-6666',
  state: 'NE',
  get_from_pie: 'fame',
  organization: 'Pie for Providers',
  password: 'testpass1234!',
  password_confirmation: 'testpass1234!',
  service_agreement_accepted: true,
  timezone: 'Central Time (US & Canada)',
  admin: true,
  stressed_about_billing: 'True',
  accept_more_subsidy_families: 'True',
  not_as_much_money: 'True',
  too_much_time: 'True'
)

@user_kate = User.where(email: 'test@test.com').first_or_create(
  active: true,
  full_name: 'Kate Donaldson',
  greeting_name: 'Kate',
  language: 'en',
  opt_in_email: true,
  opt_in_text: true,
  state: 'IL',
  get_from_pie: 'fame',
  organization: 'Pie for Providers',
  password: 'testpass1234!',
  password_confirmation: 'testpass1234!',
  phone_number: '8888888888',
  phone_type: 'cell',
  service_agreement_accepted: true,
  timezone: 'Central Time (US & Canada)',
  stressed_about_billing: 'True',
  accept_more_subsidy_families: 'True',
  not_as_much_money: 'True',
  too_much_time: 'True'
)

@user_nebraska = User.where(email: 'nebraska@test.com').first_or_create(
  active: true,
  full_name: 'Nebraska Provider',
  greeting_name: 'Candice',
  language: 'en',
  opt_in_email: true,
  opt_in_text: true,
  phone_number: '777-666-5555',
  state: 'NE',
  get_from_pie: 'fame',
  organization: 'Nebraska Child Care',
  password: 'testpass1234!',
  password_confirmation: 'testpass1234!',
  service_agreement_accepted: true,
  timezone: 'Mountain Time (US & Canada)',
  stressed_about_billing: 'True',
  accept_more_subsidy_families: 'True',
  not_as_much_money: 'True',
  too_much_time: 'True'
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
  license_type: 'family_child_care_home_i',
  county: 'Douglas',
  zipcode: '68123'
)

puts_records_in_db(Business)

# ---------------------------------------------
# Children w/ Required Approvals
# ---------------------------------------------

# find_or_create_by! a Child with the first and last,
#  and birthday set randomly between the min_age and max_age.
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/ParameterLists
def create_case(first_name:,
                last_name:,
                business: @business,
                case_number: Faker::Number.number(digits: 10),
                effective_on: Faker::Date.between(from: 11.months.ago, to: 2.months.ago),
                date_of_birth: Faker::Date.between(from: MAX_BIRTHDAY, to: MIN_BIRTHDAY),
                copay: Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000),
                add_expired_approval: false,
                add_expiring_approval: false,
                dhs_id: nil)

  frequency = copay ? Approval::COPAY_FREQUENCIES.sample : nil

  approvals = [
    Approval.find_or_create_by!(
      case_number: case_number,
      copay_cents: copay,
      copay_frequency: frequency,
      effective_on: effective_on,
      expires_on: effective_on + 1.year - 1.day
    )
  ]

  if add_expired_approval
    approvals << Approval.find_or_create_by!(
      case_number: case_number,
      copay_cents: copay ? copay - 1200 : nil,
      copay_frequency: frequency,
      effective_on: effective_on - 1.year,
      expires_on: effective_on - 1.day
    )
  end

  if add_expiring_approval
    approvals << Approval.find_or_create_by!(
      case_number: case_number,
      copay_cents: copay ? copay - 1200 : nil,
      copay_frequency: frequency,
      effective_on: effective_on - 1.year,
      expires_on: 20.days.after
      )
  end

  child = Child.find_or_initialize_by(business: business,
                                      wonderschool_id: if business == @business_nebraska
                                                         if Random.rand(10) > 3
                                                           nil
                                                         else
                                                           Faker::Name.wonderschool_id.to_i
                                                         end
                                                       end,
                                      first_name: first_name,
                                      last_name: last_name,
                                      date_of_birth: date_of_birth,
                                      dhs_id: dhs_id)
  child.approvals << approvals
  child.save!

  case child.state
  when 'IL'
    12.times do |idx|
      IllinoisApprovalAmount.create!(
        child_approval: child.active_child_approval(Time.current),
        month: 1.year.ago.at_beginning_of_month + idx.months,
        part_days_approved_per_week: rand(0..3),
        full_days_approved_per_week: rand(0..2)
      )
    end
  when 'NE'
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
  end
end
# rubocop:enable Metrics/ParameterLists
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/AbcSize

create_case(first_name: 'Maria', last_name: 'Baca')
create_case(first_name: 'Adédèjì', last_name: 'Adébísí', case_number: '1234567A')
create_case(first_name: 'Atinuke', last_name: 'Adébísí', case_number: '1234567A', add_expired_approval: true)
create_case(first_name: "K'Shawn", last_name: 'Henderson')
create_case(first_name: 'Marcus', last_name: 'Smith')
create_case(first_name: 'Sabina', last_name: 'Akers', add_expired_approval: true)
create_case(first_name: 'Mubiru', last_name: 'Karstensen')
create_case(first_name: 'Tarquinius', last_name: 'Kelly', add_expired_approval: true)
create_case(first_name: 'Rhonan', last_name: 'Shaw', business: @business_nebraska)
create_case(first_name: 'Tanim',
            last_name: 'Zaidi',
            business: @business_nebraska,
            add_expired_approval: true,
            dhs_id: '5677')
create_case(first_name: 'Jasveen',
            last_name: 'Khirwar',
            business: @business_nebraska,
            add_expired_approval: true,
            dhs_id: '5678')
create_case(first_name: 'Manuel', last_name: 'Céspedes', business: @business_nebraska, dhs_id: '1234')
create_case(first_name: 'Kevin', last_name: 'Chen', case_number: '1234567A', add_expiring_approval: true)

puts_records_in_db(Child)

Rake::Task['nebraska:rates'].invoke

Rails.logger.info 'Seeding is done!'
