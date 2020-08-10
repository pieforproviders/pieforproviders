puts "seeding"

user = User.create!(
  active: true,
  email: ENV.fetch("TESTUSER_EMAIL", "test@test.com"),
  full_name: "Kate Donaldson",
  greeting_name: "Kate",
  language: "english",
  opt_in_email: true,
  opt_in_phone: true,
  opt_in_text: true,
  organization: "Pie for Providers",
  password: ENV.fetch("TESTUSER_PASS", "testpass1234!"),
  password_confirmation: ENV.fetch("TESTUSER_PASS", "testpass1234!"),
  phone_number: "8888888888",
  phone_type: "cell",
  service_agreement_accepted: false,
  timezone: "Central Time (US & Canada)"
)

business_happy_seedlings = Business.create!(
  name: "Happy Seedlings Childcare",
  category: "licensed_center_single",
  user: user
)

site_happy_seeds_little_oaks = Site.create!(
    business: business_happy_seedlings,
    name: "Little Oaks Growing Center",
    address: "8201 1st Street",
    city: "La Grange",
    state: "WI",
    zip: "53190",
    county: "Walworth",
    qris_rating: 3,
    active: true
)
site_happy_seeds_little_sprouts = Site.create!(
    business: business_happy_seedlings,
    name: "Little Sprouts Growing Center",
    address: "123 Bighorn Lane",
    city: "Elkhorn",
    state: "WI",
    zip: "53121",
    county: "Walworth",
    qris_rating: 3,
    active: true
)



agency_WI_1 = Agency.create!(
    name: "Wisconsin State Children's Services",
    state: "WI"
)
agency_2 = Agency.create!(
    name: "Agency 2",
    state: "IL"
)


# ----------------------------------------------------
# Payments


payment_little_oaks_1 = Payment.create!(
    agency: agency_WI_1,
    site: site_happy_seeds_little_oaks,
    paid_on: Date.new(2020,8,1),
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,3,30),
    amount: 850.00,
    discrepancy: 250.00
)
payment_little_oaks_2 = Payment.create!(
    agency: agency_WI_1,
    site: site_happy_seeds_little_oaks,
    paid_on: Date.new(2020,8,1),
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,3,30),
    amount: 850.00,
    discrepancy: 250.00
)

payment_little_sprouts_1 = Payment.create!(
    agency: agency_WI_1,
    site: site_happy_seeds_little_sprouts,
    paid_on: Date.new(2020,8,1),
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,3,30),
    amount: 1000.00,
    discrepancy: 0
)
payment_little_sprouts_2 = Payment.create!(
    agency: agency_WI_1,
    site: site_happy_seeds_little_sprouts,
    paid_on: Date.new(2020,8,1),
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,3,30),
    amount: 1000.00,
    discrepancy: 0
)
sprouts_payment2 = Payment.create!(
    agency: agency_WI_1,
    site: site_happy_seeds_little_sprouts,
    paid_on: Date.new(2020,8,1),
    care_started_on: Date.new(2020,1,1),
    care_finished_on: Date.new(2020,5,15),
    amount: 1400.00,
    discrepancy: 27.50
)
