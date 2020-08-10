# frozen_string_literal: true

puts 'seeding'

user = User.where(email: ENV.fetch('TESTUSER_EMAIL', 'test@test.com')).first_or_create(
  active: true,
  full_name: 'Kate Donaldson',
  greeting_name: 'Kate',
  language: 'english',
  opt_in_email: true,
  opt_in_phone: true,
  opt_in_text: true,
  organization: 'Pie for Providers',
  password: ENV.fetch('TESTUSER_PASS', 'testpass1234!'),
  password_confirmation: ENV.fetch('TESTUSER_PASS', 'testpass1234!'),
  phone_number: '8888888888',
  phone_type: 'cell',
  service_agreement_accepted: false,
  timezone: 'Central Time (US & Canada)'
)

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


agency_1 = Agency.create!(
    name: "Community Child Care Connection",
    state: "IL"
)
agency_2 = Agency.create!(
    name: "Children's Aid and Family Services",
    state: "MA"
)
