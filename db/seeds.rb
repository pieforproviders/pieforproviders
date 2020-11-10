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

@user_kate.confirm
puts_records_in_db(User)

# ---------------------------------------------
# Locations
# ---------------------------------------------

montana = State.find_or_create_by!(name: 'Montana', abbr: 'MT')
big_horn_cty_mt = County.find_or_create_by!(name: 'Big Horn', state: montana)
hardin_zipcode = Zipcode.find_or_create_by!(city: 'Hardin', county: big_horn_cty_mt, state: big_horn_cty_mt.state, code: '12345')

illinois = State.find_or_create_by!(name: 'Illinois', abbr: 'IL')
cook_county = County.find_or_create_by!(name: 'Cook', state: illinois)
cook_zip_60686 = Zipcode.find_or_create_by!(state: cook_county.state, county: cook_county, code: '60686', city: 'Chicago')
cook_zip_60688 = Zipcode.find_or_create_by!(state: cook_county.state, county: cook_county, code: '60688', city: 'Chicago')

lake_county = County.find_or_create_by!(name: 'Lake', state: illinois)

# ---------------------------------------------
# Businesses
# ---------------------------------------------

@biz_happy_seedlings = Business.where(name: 'Happy Seedlings Childcare', user: @user_kate).first_or_create(
  license_type: Licenses.types.keys.first,
  county: big_horn_cty_mt,
  zipcode: hardin_zipcode
)

@biz_goslings = Business.where(name: 'Goslings Grow', user: @user_kate).first_or_create(
  license_type: Licenses.types.keys.first,
  county: cook_county,
  zipcode: cook_zip_60688
)
@biz_lil_ducks = Business.where(name: 'Lil Baby Ducklings', user: @user_kate).first_or_create(
  license_type: Licenses.types.keys.first,
  county: cook_county,
  zipcode: cook_zip_60686
)

puts_records_in_db(Business)

# ---------------------------------------------
# Children w/ Required Approvals
# ---------------------------------------------

# find_or_create_by! a Child with the full_name,
#  and birthday set randomly between the min_age and max_age.
def child_named(full_name, date_of_birth: nil,
                min_birthday: MIN_BIRTHDAY, max_birthday: MAX_BIRTHDAY,
                business: @biz_happy_seedlings,
                case_number: Faker::Number.number(digits: 10),
                copay: Faker::Number.decimal(l_digits: 3, r_digits: 2),
                copay_frequency: [nil].concat(Approval::COPAY_FREQUENCIES).sample,
                effective_on: Faker::Date.between(from: 1.year.ago, to: Time.zone.today),
                expires_on: effective_on + 1.year)

  Child.find_or_create_by!(business: business,
                           full_name: full_name,
                           date_of_birth: (date_of_birth.nil? ? Faker::Date.between(from: max_birthday, to: min_birthday) : date_of_birth),
                           approvals: [
                             Approval.create!(
                               case_number: case_number,
                               copay: copay,
                               copay_frequency: copay_frequency,
                               effective_on: effective_on,
                               expires_on: expires_on
                             )
                           ])
end

# Kids in Happy Seedlings Childcare
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

today = Date.current

il_sr_rule = IllinoisSubsidyRule.first_or_create!

two_hundred_days_ago = today - 200
il_9_this_year = SubsidyRule.find_or_create_by(
  name: 'This year until age 9',
  max_age: 9,
  license_type: Licenses.types.values.sample,
  county: cook_county,
  state: cook_county.state,
  effective_on: two_hundred_days_ago,
  expires_on: two_hundred_days_ago + 1.year - 1.day,
  subsidy_ruleable: il_sr_rule
)
il_9_last_year = SubsidyRule.find_or_create_by(
  name: 'Last year until age 9',
  max_age: 9,
  license_type: Licenses.types.values.sample,
  county: cook_county,
  state: cook_county.state,
  effective_on: two_hundred_days_ago - 1.years,
  expires_on: two_hundred_days_ago - 1.day,
  subsidy_ruleable: il_sr_rule
)
il_18_this_year = SubsidyRule.find_or_create_by(
  name: 'This year until age 18',
  max_age: 18,
  license_type: Licenses.types.values.sample,
  county: cook_county,
  state: cook_county.state,
  effective_on: two_hundred_days_ago,
  expires_on: two_hundred_days_ago + 1.year - 1.day,
  subsidy_ruleable: il_sr_rule
)
il_18_last_year = SubsidyRule.find_or_create_by(
  name: 'Last year until age 18',
  max_age: 18,
  license_type: Licenses.types.values.sample,
  county: cook_county,
  state: cook_county.state,
  effective_on: two_hundred_days_ago - 1.year,
  expires_on: two_hundred_days_ago - 1.day,
  subsidy_ruleable: il_sr_rule
)
il_lake_18_this_year = SubsidyRule.find_or_create_by(
  name: 'This year until age 18',
  max_age: 18,
  license_type: Licenses.types.values.sample,
  county: lake_county,
  state: lake_county.state,
  effective_on: two_hundred_days_ago,
  expires_on: two_hundred_days_ago + 1.year - 1.day,
  subsidy_ruleable: il_sr_rule
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
                    earliest_checkin_hour: 7,
                    child: Child.first)

  days_attended = dates_skipping_most_weekends(first_date: first_date, last_date: last_date)
  days_attended.each do |day_attended|
    random_checkin_time = (earliest_checkin_hour * 60) + Random.rand(60 * RAND_CHECKIN_HRS_RANGE).minutes
    random_checkout_time = random_checkin_time + Random.rand(60 * RAND_CHECKOUT_HRS_RANGE).minutes

    # Attendances are a type of BillableOccurrence so we should always create them this way
    BillableOccurrence.find_or_create_by!(child_approval: child.child_approvals[0], billable: Attendance.create!(check_in: day_attended + random_checkin_time,
                                                                                                                 check_out: day_attended + random_checkout_time))
  end
end

def latest_date(date1, date2)
  [date1, date2].compact.max
end

# Attendance for Maria between January 1 and March 31
make_attendance(first_date: JAN_1,
                last_date: MAR_31,
                earliest_checkin_hour: 7,
                child: maria)

# Attendance for K'Shawn between January 1 and March 31
make_attendance(first_date: JAN_1,
                last_date: MAR_31,
                earliest_checkin_hour: 7, child: kshawn)

# ------------

# Attendance for Maria between April 1 and June 30
make_attendance(first_date: APR_1,
                last_date: JUN_30,
                earliest_checkin_hour: 7,
                child: maria)

# Attendance for K'Shawn between April 1 and June 30
make_attendance(first_date: APR_1,
                last_date: JUN_30,
                earliest_checkin_hour: 7,
                child: kshawn)

# Attendance for mubiru between April 1 and June 30
make_attendance(first_date: APR_1,
                last_date: JUN_30,
                earliest_checkin_hour: 7,
                child: mubiru)

puts_records_in_db(Attendance)

# ---------------------------------------------

puts 'Seeding is done!'
