# frozen_string_literal: true

ActionMailer::Base.perform_deliveries = false

puts 'seeding'

Rake::Task['pie4providers:address_lookups:import_all'].invoke

user = User.where(email: ENV.fetch('TESTUSER_EMAIL', 'test@test.com')).first_or_create(
  active: true,
  full_name: 'Kate Donaldson',
  greeting_name: 'Kate',
  language: 'english',
  opt_in_email: true,
  opt_in_text: true,
  organization: 'Pie for Providers',
  password: ENV.fetch('TESTUSER_PASS', 'testpass1234!'),
  password_confirmation: ENV.fetch('TESTUSER_PASS', 'testpass1234!'),
  phone_number: '8888888888',
  phone_type: 'cell',
  service_agreement_accepted: true,
  timezone: 'Central Time (US & Canada)'
)

user.confirm

business = Business.where(name: 'Happy Seedlings Childcare', user: user).first_or_create(
  category: 'licensed_center_single'
)

site = Site.where(name: 'Prairie Center', business: business).first_or_create(
  address: '8238 Rhinebeck Dr',
  city: 'Calhoun',
  county: 'Wyatt',
  state: 'MT',
  zip: '89234'
)
site_happy_seeds_little_oaks = Site.where(name:'Little Oaks Growing Center',
                                          business: business).first_or_create(
    address: '8201 1st Street',
    city: 'La Grange',
    state: 'WI',
    zip: '53190',
    county: 'Walworth',
    qris_rating: 3,
    active: true
)
site_happy_seeds_little_sprouts = Site.where(name:'Little Sprouts Growing Center',
                                            business: business).first_or_create(
    address: '123 Bighorn Lane',
    city: 'Elkhorn',
    state: 'WI',
    zip: '53121',
    county: 'Walworth',
    qris_rating: 3,
    active: true
)

agency_WI = Agency.where(name: "Wisconsin Children's Services",
                           state: 'WI').first_or_create(
    active: true
)
agency_1 = Agency.where(name: "Community Child Care Connection",
                        state: "IL").first_or_create(
    active: true
  )
agency_2 = Agency.where(name: "Children's Aid and Family Services",
                        state: "MA").first_or_create(
    active: true
)

# ----------------------------------------------------
# Payments
#
Payment.where(agency: agency_WI, site: site_happy_seeds_little_oaks,
              paid_on: Date.new(2020,8,1)).first_or_create(
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,3,30),
    amount_cents: 85_000,
    discrepancy_cents: 25_000
)
Payment.where(agency: agency_WI, site: site_happy_seeds_little_sprouts,
              paid_on: Date.new(2020,8,1)).first_or_create(
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,3,30),
    amount_cents: 100_000,
    discrepancy_cents: 0
)
Payment.where(agency: agency_WI, site: site_happy_seeds_little_sprouts,
              paid_on: Date.new(2020,8,10)).first_or_create(
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,5,15),
    amount_cents: 140_000,
    discrepancy_cents: 2_750
)

# -----------------------------------------------------------------------------
# Subsidy Rules
#  TODO: must first import states, counties, cities, zips?
#
state_il = Lookup::State.first_or_create!( abbr: 'IL', name: 'Illinois')
county_il_cook = Lookup::County.first_or_create!(name: 'Cook', state: state_il)

# TODO: after PR 252 is merged, replace the license_type line with: license_type: Licenses.types.values.sample,
SubsidyRule.first_or_create!(
    name: 'Rule 1',
    county: county_il_cook,
    state: state_il,
    max_age: 18,
    part_day_rate: 18.00,
    full_day_rate: 32.00,
    part_day_max_hours: 5,
    full_day_max_hours: 12,
    full_plus_part_day_max_hours: 18,
    full_plus_full_day_max_hours: 24,
    part_day_threshold: 5,
    full_day_threshold: 6,
    license_type: SubsidyRule::LICENSE_TYPES.sample,
    qris_rating: '3'
)
