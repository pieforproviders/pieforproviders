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

    ## LDDS FCCHII

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
      name: 'Infant Hourly LDDS accredited FCCHI step_three',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHI step_three',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '36.75',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHI step_three',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHI step_three',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '35.70',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHI step_three',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHI step_three',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '34.75',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHI step_three',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHI step_three',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '33.60',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

	  #Accredited/Step3 FCCHII
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHII step_three',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHII step_three',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '36.75',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHII step_three',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHII step_three',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '35.70',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHII step_three',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.25',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHII step_three',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '34.75',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHII step_three',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHII step_three',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '33.60',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

	  #Accredited/Step_4 FCCHI
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHI Step_4',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '6.10',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
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
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
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
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
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
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
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
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
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
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
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
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
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
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

	  #Accredited/step_four FCCHII
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHII step_four',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '6.10',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHII step_four',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '38.60',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHII step_four',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.55',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHII step_four',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '37.50',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHII step_four',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.55',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHII step_four',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '36.40',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHII step_four',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '6.10',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHII step_four',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '35.30',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

	  #Accredited/step_five FCCHI
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHI step_five',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '6.40',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHI step_five',
      rate_type: 'daily',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '40.55',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHI step_five',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHI step_five',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '39.40',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHI step_five',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHI step_five',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '38.20',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHI step_five',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '6.40',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHI step_five',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_i',
      max_age: 18,
      region: 'LDDS',
      amount: '37.50',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

	  #Accredited/step_five FCCHII
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited FCCHII step_five',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '6.40',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited FCCHII step_five',
      rate_type: 'daily',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '40.55',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited FCCHII step_five',
      rate_type: 'hourly',
      license_type: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited FCCHII step_five',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '39.40',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited FCCHII step_five',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '5.80',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited FCCHII step_five',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '38.20',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited FCCHII step_five',
      rate_type: 'hourly',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '6.40',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited FCCHII step_five',
      rate_type: 'daily',
      license_typse: 'family_child_care_home_ii',
      max_age: 18,
      region: 'LDDS',
      amount: '37.50',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    #Unaccredited Licensed Centers LDDS
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS unaccredited Licensed Center',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '55.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS unaccredited Licensed Center',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.65',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS unaccredited Licensed Center',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '50.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS unaccredited Licensed Center',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS unaccredited Licensed Center',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '45.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS unaccredited Licensed Center',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '6.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS unaccredited Licensed Center',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '40.00',
      accredited_rate: false
    )

    #Accredited LDDS Licensed Centers LDDS step_three
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.40',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '57.75',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.05',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS accredited Licensed Center step_three',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '52.50',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS accredited Licensed Center step_three',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.35',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS accredited Licensed Center step_three',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '47.25',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS accredited Licensed Center step_three',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '6.85',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited Licensed Center step_three',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '42.00',
      qris_rating: 'step_three',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: true
    )

    #Unaccredited LDDS Licensed Centers LDDS step_four
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS unaccredited Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.85',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS unaccredited Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '60.65',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS unaccredited Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.45',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS unaccredited Licensed Center step_four',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '55.15',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS unaccredited Licensed Center step_four',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.75',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS unaccredited Licensed Center step_four',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '49.65',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS unaccredited Licensed Center step_four',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.20',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS unaccredited Licensed Center step_four',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '44.10',
      qris_rating: 'step_four',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    #Unaccredited LDDS Licensed Centers LDDS step_five
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS unaccredited Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '9.30',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS unaccredited Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '63.70',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS unaccredited Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.90',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS unaccredited Licensed Center step_five',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '57.90',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS unaccredited Licensed Center step_five',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.10',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS unaccredited Licensed Center step_five',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '52.10',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS unaccredited Licensed Center step_five',
      rate_type: 'hourly',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.55',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS unaccredited Licensed Center step_five',
      rate_type: 'daily',
      license_typse: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '46.35',
      qris_rating: 'step_five',
      use_qris_rating_to_determine_rate: true,
      accredited_rate: false
    )

    #License Exempt LD
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LD License Exempt Home',
      rate_type: 'daily',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LD License Exempt Home',
      rate_type: 'daily',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LD License Exempt Home',
      rate_type: 'daily',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50',
      accredited_rate: false
    )

    #License Exempt DS
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily DS License Exempt Home',
      rate_type: 'daily',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily DS License Exempt Home',
      rate_type: 'daily',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25',
      accredited_rate: false
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily DS License Exempt Home',
      rate_type: 'daily',
      license_typse: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00',
      accredited_rate: false
    )

    #Other FCCHI
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
	end
end