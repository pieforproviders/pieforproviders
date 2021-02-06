# frozen_string_literal: true

return unless ENV.fetch('ALLOW_SEEDING', 'false') == 'true'

require 'faker'

# This seeds the db with data. It is not used in production.
# Use :find_or_create_by! or :first_or_create! when creating objects

ActionMailer::Base.perform_deliveries = false

puts 'Seeding.......'

THIS_YEAR = Date.current.year
JAN_1 = Date.new(THIS_YEAR, 1, 1)
MAR_31 = Date.new(THIS_YEAR, 3, 31)
APR_1 = Date.new(THIS_YEAR, 4, 1)
JUN_30 = Date.new(THIS_YEAR, 6, 30)

# minimum birthdates (ages)
MIN_BIRTHDAY = (Time.zone.now - 2.weeks)
MAX_BIRTHDAY = (Time.zone.now - 14.years)

# Use puts to show the number of records in the database for a given class
def puts_records_in_db(klass)
  puts " ... #{klass.count} #{klass.name.pluralize} now in the db"
end

# ---------------------------------------------
# Subsidy Rules
# ---------------------------------------------

# currently active rule
SubsidyRule.first_or_create!(
  name: 'Rule 1',
  max_age: 18,
  license_type: Licenses.types.values.sample,
  county: 'Cook',
  state: 'IL',
  effective_on: Faker::Date.between(from: 10.years.ago, to: Time.zone.today),
  subsidy_ruleable: IllinoisSubsidyRule.first_or_create!(full_day_rate: 29.5, part_day_rate: 15.4, attendance_threshold: 0.49)
)

puts_records_in_db(SubsidyRule)

# ---------------------------------------------
# Users
# ---------------------------------------------

@user_admin = User.where(email: 'admin@test.com').first_or_create!(
  full_name: 'Admin User',
  greeting_name: 'Addie',
  language: 'spanish',
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
  language: 'english',
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
  language: 'english',
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
  license_type: Licenses.types.keys.first,
  county: 'Cook',
  zipcode: '60606'
)

@business_nebraska = Business.where(name: 'Nebraska Home Child Care', user: @user_nebraska).first_or_create!(
  license_type: Licenses.types.keys.first,
  county: 'Cook',
  zipcode: '68123'
)

puts_records_in_db(Business)

# ---------------------------------------------
# Children w/ Required Approvals
# ---------------------------------------------

# find_or_create_by! a Child with the full_name,
#  and birthday set randomly between the min_age and max_age.
def create_case(full_name,
                business: @business,
                case_number: Faker::Number.number(digits: 10),
                effective_on: Faker::Date.between(from: 8.months.ago, to: Time.zone.today),
                date_of_birth: Faker::Date.between(from: MAX_BIRTHDAY, to: MIN_BIRTHDAY),
                copay: Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000),
                copay_frequency: nil,
                add_expired_approval: false)
  expires_on = effective_on + 1.year - 1.day

  copay_frequency = copay ? Approval::COPAY_FREQUENCIES.sample : nil

  approvals = [
    Approval.find_or_create_by!(
      case_number: case_number,
      copay_cents: copay,
      copay_frequency: copay_frequency,
      effective_on: effective_on,
      expires_on: expires_on
    )
  ]

  if add_expired_approval
    approvals << Approval.find_or_create_by!(
      case_number: case_number,
      copay_cents: copay ? copay - 1200 : nil,
      copay_frequency: copay_frequency,
      effective_on: effective_on - 1.year,
      expires_on: effective_on - 1.day
    )
  end

  child = Child.find_or_initialize_by(business: business,
                                      full_name: full_name,
                                      date_of_birth: date_of_birth)
  child.approvals << approvals
  child.save!

  12.times do |idx|
    IllinoisApprovalAmount.create!(
      child_approval: child.active_child_approval(DateTime.now),
      month: DateTime.now.at_beginning_of_month + idx.months,
      part_days_approved_per_week: rand(0..3),
      full_days_approved_per_week: rand(0..2)
    )
  end
end

maria = create_case('Maria Baca')
adedji = create_case('Adédèjì Adébísí', case_number: '1234567A')
atinuke = create_case('Atinuke Adébísí', case_number: '1234567A', add_expired_approval: true)
kshawn = create_case("K'Shawn Henderson")
marcus = create_case('Marcus Smith')
sabina = create_case('Sabina Akers', add_expired_approval: true)
mubiru = create_case('Mubiru Karstensen')
tarquinius = create_case('Tarquinius Kelly', add_expired_approval: true)
rhonan = create_case('Rhonan Shaw', business: @business_nebraska)
tanim = create_case('Tanim Zaidi', business: @business_nebraska, add_expired_approval: true)
jasveen = create_case('Jasveen Khirwar', business: @business_nebraska, add_expired_approval: true)
manuel = create_case('Manuel Céspedes', business: @business_nebraska)

puts_records_in_db(Child)

puts 'Seeding is done!'
