user = User.create!(
  active: true,
  email: ENV.fetch("TESTUSER_EMAIL", "test@test.com"),
  full_name: "Kate Donaldson",
  greeting_name: "Kate",
  language: "english",
  mobile: "8888888888",
  opt_in_email: true,
  opt_in_phone: true,
  opt_in_text: true,
  organization: "Pie for Providers",
  password: ENV.fetch("TESTUSER_PASS", "testpass1234!"),
  password_confirmation: ENV.fetch("TESTUSER_PASS", "testpass1234!"),
  phone: "8888888888",
  service_agreement_accepted: false,
  timezone: "Central Time (US & Canada)"
)