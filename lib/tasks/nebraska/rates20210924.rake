# frozen_string_literal: true

# This will enter all NE Hourly & Daily Rates for Family Child Care Home I & II as of 2021/08/13, subject to change
desc 'Import all Nebraska Hourly and Daily Rates for Family Child Care Home I & II as of 2021/08/13'
namespace :nebraska do
  task rates20210924: :environment do
    # rubocop:disable Rails/SkipsModelValidations
    NebraskaRate.where(effective_on: '2021-01-01').update_all(expires_on: '2021-06-30')
    # rubocop:enable Rails/SkipsModelValidations
    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly LDDS unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly LDDS unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly LDDS accredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly LDDS accredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly Other county unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly Other county unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly Other county accredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'Other',
      amount: '4.95',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly Other county accredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'Other',
      amount: '4.95',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly LDDS unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly LDDS unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly Other county unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly Other county unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly Other county accredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'Other',
      amount: '4.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly Other county accredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'Other',
      amount: '4.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly LDDS unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly LDDS unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly Other county unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly Other county unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly Other county accredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '4.40',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly Other county accredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '4.40',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly LDDS unaccredited FCCHI',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly LDDS unaccredited FCCHII',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly LDDS accredited FCCHI',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly LDDS accredited FCCHII',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly Other county unaccredited FCCHI',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly Other county unaccredited FCCHII',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '3.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly Other county accredited FCCHI',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '4.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly Other county accredited FCCHII',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '4.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily LDDS unaccredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily LDDS unaccredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily LDDS accredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '34.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily LDDS accredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '34.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily Other county unaccredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'Other',
      amount: '27.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily Other county unaccredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'Other',
      amount: '27.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily Other county accredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'Other',
      amount: '34.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily Other county accredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'Other',
      amount: '34.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily LDDS unaccredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'LDDS',
      amount: '31.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily LDDS unaccredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'LDDS',
      amount: '31.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily LDDS accredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily LDDS accredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily Other county unaccredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'Other',
      amount: '25.95',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily Other county unaccredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'Other',
      amount: '25.95',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily Other county accredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 36,
      region: 'Other',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily Other county accredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 36,
      region: 'Other',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily LDDS unaccredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '30.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily LDDS unaccredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '30.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily LDDS accredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily LDDS accredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily Other county unaccredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '25.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily Other county unaccredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '25.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily Other county accredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily Other county accredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '32.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily LDDS unaccredited FCCHI',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '30.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily LDDS unaccredited FCCHII',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '30.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily LDDS accredited FCCHI',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'LDDS',
      amount: '30.80',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily LDDS accredited FCCHII',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'LDDS',
      amount: '30.80',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily Other county unaccredited FCCHI',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '25.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily Other county unaccredited FCCHII',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '25.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily Other county accredited FCCHI',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: nil,
      region: 'Other',
      amount: '30.80',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily Other county accredited FCCHII',
      school_age: true,
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: nil,
      region: 'Other',
      amount: '30.80',
      accredited_rate: true
    )
    Attendance.where('check_in >= ?', '2021-07-01').each do |attendance|
      attendance.update!(updated_at: Time.current)
    end
  end
end
