user = User.first_or_create!(
  email: ENV.fetch("TESTUSER_EMAIL", "test@test.com"),
  full_name: "Kate Donaldson",
  greeting_name: "Kate",
  phone: "8888888888",
  mobile: "8888888888",
  opt_in_text: true,
  opt_in_email: true,
  opt_in_phone: true,
  active: true,
  language: "english",
  service_agreement_accepted: false,
  timezone: "Central Time (US & Canada)"
)