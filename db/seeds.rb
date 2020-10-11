# frozen_string_literal: true

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

# ---------------------------------------------

# Use puts to show the number of records in the database for a given class
def puts_records_in_db(klass)
  puts " ... #{klass.count} #{klass.name.pluralize} now in the db"
end

# ---------------------------------------------

@user_kate = User.where(email: ENV.fetch('TESTUSER_EMAIL', 'test@test.com')).first_or_create(
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

@user_kate.confirm
puts_records_in_db(User)

# ---------------------------------------------
# Locations
# ---------------------------------------------

montana = State.find_or_create_by!(name: 'Montana', abbr: 'MT')
big_horn_cty_mt = County.find_or_create_by!(name: 'Big Horn', state: montana)
hardin_zipcode = Zipcode.first_or_create!(city: 'Hardin', county: big_horn_cty_mt, state: big_horn_cty_mt.state, code: '12345')

# ---------------------------------------------
# Businesses
# ---------------------------------------------

@business = Business.where(name: 'Happy Seedlings Childcare', user: @user_kate).first_or_create(
  license_type: Licenses.types.keys.first,
  county: big_horn_cty_mt,
  zipcode: hardin_zipcode
)

puts_records_in_db(Business)

# ---------------------------------------------
# Children
# ---------------------------------------------

# find_or_create_by! a Child with the full_name,
#  and birthday set randomly between the min_age and max_age.
def child_named(full_name, min_birthday: MIN_BIRTHDAY,
                max_birthday: MAX_BIRTHDAY,
                business: @business)
  Child.find_or_create_by!(business: business,
                           full_name: full_name,
                           date_of_birth: Faker::Date.between(from: max_birthday, to: min_birthday))
end

maria = child_named('Maria Baca')
kshawn = child_named("K'Shawn Henderson")
marcus = child_named('Marcus Smith')
sabina = child_named('Sabina Akers')
mubiru = child_named('Mubiru Karstensen')
tarq = child_named('Tarquinius Kelly')

puts_records_in_db(Child)

# ---------------------------------------------
# Subsidy Rules
# ---------------------------------------------

sr_rule_1 = SubsidyRule.first_or_create!(
  name: 'Rule 1',
  max_age: 18,
  part_day_rate: 18.00,
  full_day_rate: 32.00,
  part_day_max_hours: 5,
  full_day_max_hours: 12,
  full_plus_part_day_max_hours: 18,
  full_plus_full_day_max_hours: 24,
  part_day_threshold: 5,
  full_day_threshold: 6,
  license_type: Licenses.types.values.sample,
  qris_rating: '3',
  county: big_horn_cty_mt,
  state: big_horn_cty_mt.state
)

puts_records_in_db(SubsidyRule)

# ---------------------------------------------
# Attendance
# ---------------------------------------------

puts ' Now creating attendance records...'

# @return [Array[Date]] - list of days, starting with the first date (inclusive),
#   ending with the last_date (inclusive),
#   and including random weekends dates (using the percent_weekends)
#   If skip_all_weekends, then absolutely no weekend dates are returned
def dates_skipping_most_weekends(first_date: Date.current - 60.days,
                                 last_date: Date.current,
                                 percent_on_weekends: 0.10,
                                 skip_all_weekends: false)
  dates = []
  num_days = last_date - first_date
  num_days.to_i.times do |day_num|
    this_date = (first_date + (day_num - 1)).to_datetime
    dates << this_date.to_date if this_date.on_weekday? || (!skip_all_weekends && Faker::Boolean.boolean(true_ratio: percent_on_weekends))
  end
  dates
end

RAND_CHECKIN_HRS_RANGE = 3 # checkin will be within 3 hours of the earliest checkin hour
RAND_CHECKOUT_HRS_RANGE = 18 # checkout will be within 18 hours of checkin

# create Attendance records, some random amount of part and full days.
def make_attendance(first_date: Date.current - 10,
                    last_date: Date.current,
                    earliest_checkin_hour: 7)

  days_attended = dates_skipping_most_weekends(first_date: first_date, last_date: last_date)
  days_attended.each do |day_attended|
    random_checkin_time = (earliest_checkin_hour * 60) + Random.rand(60 * RAND_CHECKIN_HRS_RANGE).minutes
    random_checkout_time = random_checkin_time + Random.rand(60 * RAND_CHECKOUT_HRS_RANGE).minutes

    Attendance.find_or_create_by!(starts_on: day_attended,
                                  check_in: day_attended + random_checkin_time,
                                  check_out: day_attended + random_checkout_time)
  end
end

def latest_date(date1, date2)
  [date1, date2].compact.max
end

# Attendance for Maria between January 1 and March 31
make_attendance(first_date: JAN_1,
                last_date: MAR_31,
                earliest_checkin_hour: 7)

# Attendance for K'Shawn between January 1 and March 31
make_attendance(first_date: JAN_1,
                last_date: MAR_31,
                earliest_checkin_hour: 7)

# ------------

# Attendance for Maria between April 1 and June 30
make_attendance(first_date: APR_1,
                last_date: JUN_30,
                earliest_checkin_hour: 7)

# Attendance for K'Shawn between April 1 and June 30
make_attendance(first_date: APR_1,
                last_date: JUN_30,
                earliest_checkin_hour: 7)

# Attendance for mubiru between April 1 and June 30
make_attendance(first_date: APR_1,
                last_date: JUN_30,
                earliest_checkin_hour: 7)

puts_records_in_db(Attendance)

# ---------------------------------------------

puts 'Seeding is done!'
