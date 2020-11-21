# frozen_string_literal: true

require 'faker'

desc 'Add second user cases'
task dashboard_data: :environment do
  # minimum birthdates (ages)
  MIN_BIRTHDAY = (Time.zone.now - 2.weeks)
  MAX_BIRTHDAY = (Time.zone.now - 14.years)

  ActionMailer::Base.perform_deliveries = false

  # Create an new non-admin user
  @non_admin = User.where(email: 'second_user@test.com').first_or_create!(
    active: true,
    full_name: 'Second User',
    greeting_name: 'Seco',
    language: 'spanissh',
    opt_in_email: true,
    opt_in_text: true,
    organization: 'Illinois Child Care Alliance',
    password: 'testpass1234!',
    password_confirmation: 'testpass1234!',
    phone_number: '7777777777',
    phone_type: 'cell',
    service_agreement_accepted: true,
    timezone: 'Eastern Time (US & Canada)'
  )

  @non_admin.confirm

  montana = State.find_by!(name: 'Montana', abbr: 'MT')
  big_horn_cty_mt = County.find_by!(name: 'BIG HORN', state: montana)
  hardin_zipcode = Zipcode.find_by!(city: 'Hardin', county: big_horn_cty_mt, state: big_horn_cty_mt.state)

  @business = Business.where(name: 'Second Childcare', user: @non_admin).first_or_create!(
    license_type: Licenses.types.keys.sample,
    county: big_horn_cty_mt,
    zipcode: hardin_zipcode
  )

  def create_case(full_name,
                  business: @business,
                  case_number: Faker::Number.number(digits: 10),
                  effective_on: Faker::Date.between(from: 1.year.ago, to: Time.zone.today),
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

    Child.find_or_create_by!(business: business,
                             full_name: full_name,
                             date_of_birth: date_of_birth,
                             approvals: approvals)
  end

  5.times do
    create_case(Faker::Movies::PrincessBride.character, case_number: Random.rand(10) > 7 ? nil : Faker::IDNumber.invalid, add_expired_approval: Random.rand(10) > 7)
  end
end
