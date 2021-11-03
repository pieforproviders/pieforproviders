# frozen_string_literal: true

# This will enter all NE Hourly & Daily Rates for Family Child Care Home I & II as of 2021/08/13, subject to change
desc 'Import all Nebraska Hourly and Daily Rates for Family Child Care Home I & II as of 2021/08/13'
namespace :nebraska do
  task rates20211103: :environment do
    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly LDDS unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.60',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly Other county unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly LDDS accredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.70',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly Other county accredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '7.70',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily LDDS unaccredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '50.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily Other county unaccredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '35.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily LDDS accredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '52.50',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily Other county accredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '46.20',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly LDDS unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'LDDS',
      amount: '7.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly Other county unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'Other',
      amount: '4.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly LDDS accredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'LDDS',
      amount: '7.35',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly Other county accredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'Other',
      amount: '6.60',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily LDDS unaccredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'LDDS',
      amount: '45.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily Other county unaccredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'Other',
      amount: '33.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily LDDS accredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'LDDS',
      amount: '47.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily Other county accredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 36,
      region: 'Other',
      amount: '45.00',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly LDDS unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '6.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly Other county unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '4.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly LDDS accredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '6.60',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly Other county accredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '6.60',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily LDDS unaccredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '41.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily Other county unaccredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '31.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily LDDS accredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '42.90',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily Other county accredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '42.90',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly LDDS unaccredited Licensed Center',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '6.10',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly Other county unaccredited Licensed Center',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '4.10',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly LDDS accredited Licensed Center',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '6.60',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly Other county accredited Licensed Center',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '6.60',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily LDDS unaccredited Licensed Center',
      school_age: true,
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '37.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily Other county unaccredited Licensed Center',
      school_age: true,
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '30.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily LDDS accredited Licensed Center',
      school_age: true,
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'LDDS',
      amount: '42.90',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily Other county accredited Licensed Center',
      school_age: true,
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: nil,
      region: 'Other',
      amount: '42.90',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Hourly Other county License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '2.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Infant Daily Other county License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '13.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 36,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 36,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Hourly Other county License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 36,
      region: 'Other',
      amount: '2.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 36,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 36,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Toddler Daily Other county License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 36,
      region: 'Other',
      amount: '13.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Hourly Other county License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Other',
      amount: '2.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'Preschool Daily Other county License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Other',
      amount: '13.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly LD License Exempt Home',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly DS License Exempt Home',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Hourly Other county License Exempt Home',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Other',
      amount: '2.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily LD License Exempt Home',
      school_age: true,
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily DS License Exempt Home',
      school_age: true,
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge Daily Other county License Exempt Home',
      school_age: true,
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: nil,
      region: 'Other',
      amount: '13.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'NotSchoolAge License Exempt Family In-Home',
      rate_type: 'hourly',
      license_type: 'family_in_home',
      max_age: nil,
      region: 'All',
      amount: '9.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2021-07-01',
      name: 'SchoolAge License Exempt Family In-Home',
      school_age: true,
      rate_type: 'hourly',
      license_type: 'family_in_home',
      max_age: nil,
      region: 'All',
      amount: '9.00',
      accredited_rate: false
    )
  end
end
