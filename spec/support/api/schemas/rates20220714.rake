# frozen_string_literal: true

# This will enter all NE Hourly & Daily Rates for Family Child Care Home I & II as of 2022/07/14, subject to change
desc 'Import all Nebraska Hourly and Daily Rates for Family Child Care Home I & II as of 2021/08/13'
namespace :nebraska do
	task rates20220714: :environment do
		NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS unaccredited FCCHI',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '35.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS unaccredited FCCHI',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS unaccredited FCCHI',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '34.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS unaccredited FCCHI',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS unaccredited FCCHI',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '33.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS unaccredited FCCHI',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS unaccredited FCCHI',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: false
    )

    ## FCCHII

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS unaccredited FCCHII',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '35.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS unaccredited FCCHII',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS unaccredited FCCHII',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '34.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS unaccredited FCCHII',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS unaccredited FCCHII',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '33.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS unaccredited FCCHII',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS unaccredited FCCHII',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '32.00',
      accredited_rate: false
    )

    #Accredited/Step3 FCCHI
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHI Step_3',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHI Step_3',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '36.75',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHI Step_3',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHI Step_3',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '35.70',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHI Step_3',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHI Step_3',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '34.75',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHI Step_3',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHI Step_3',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '33.60',
      accredited_rate: true
    )
	end

	#Accredited/Step3 FCCHII
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHII Step_3',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHII Step_3',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '36.75',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHII Step_3',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHII Step_3',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '35.70',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHII Step_3',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHII Step_3',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '34.75',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHII Step_3',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHII Step_3',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '33.60',
      accredited_rate: true
    )
	end

	#Accredited/Step_4 FCCHI
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '6.10',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '38.60',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '37.50',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '36.40',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '6.10',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '35.30',
      accredited_rate: true
    )
	end

	#Accredited/Step_4 FCCHII
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '6.10',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '38.60',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '37.50',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.55',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '36.40',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '6.10',
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHI Step_4',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '35.30',
      accredited_rate: true
    )
	end
end