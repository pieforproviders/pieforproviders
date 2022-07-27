# frozen_string_literal: true

# This will enter all NE Hourly & Daily Rates for Family Child Care Home I & II as of 2022/07/14, subject to change
desc 'Import all Nebraska Hourly and Daily Rates for Family Child Care Home I & II as of 2021/08/13'
namespace :nebraska do
  task rates20220714: :environment do
    %w[step_one step_two not_rated].each do |rating|
      # Licensed Centers LDDS
      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Infant Hourly LDDS Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '8.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Infant Daily LDDS Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '55.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Toddler Hourly LDDS Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '7.65',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Toddler Daily LDDS Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '50.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Preschool Hourly LDDS Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '7.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Preschool Daily LDDS Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '45.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'School_Age Hourly LDDS Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '6.50',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'School_Age Daily LDDS Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'LDDS',
        amount: '40.00',
        quality_rating: rating
      )

      # Other County Licensed Centers
      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Infant Hourly Other county Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '5.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Infant Daily Other county Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '36.30',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Toddler Hourly Other county Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '5.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Toddler Daily Other county Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '35.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Preschool Hourly Other county Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '5.00',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'Preschool Daily Other county Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '32.25',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'School_Age Hourly Other county Licensed Center',
        rate_type: 'hourly',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '4.75',
        quality_rating: rating
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: 'School_Age Daily Other county Licensed Center',
        rate_type: 'daily',
        license_type: 'licensed_center',
        max_age: 18,
        region: 'Other',
        amount: '32.00',
        quality_rating: rating
      )
    end

    { FCCHI: 'family_child_care_home_i', FCCHII: 'family_child_care_home_ii' }.each do |abbr, license_type|
      %w[step_one step_two not_rated].each do |rating|
        # Licensed Family Child Care Homes I
        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Infant Hourly LDDS #{abbr}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '5.50',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Infant Daily LDDS #{abbr}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '35.50',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Toddler Hourly LDDS #{abbr}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '5.00',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Toddler Daily LDDS #{abbr}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '34.00',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Preschool Hourly LDDS #{abbr}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '5.00',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Preschool Daily LDDS #{abbr}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '33.00',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "School_Age Hourly LDDS #{abbr}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '5.50',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "School_Age Daily LDDS #{abbr}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'LDDS',
          amount: '32.00',
          quality_rating: rating
        )
      end

      # LDDS step_three FCCHI
      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Hourly LDDS #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.80',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Daily LDDS #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '36.75',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Hourly LDDS #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.25',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Daily LDDS #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '35.70',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Hourly LDDS #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.25',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Daily LDDS #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '34.65',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Hourly LDDS #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.80',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Daily LDDS #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '33.60',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Hourly LDDS #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '6.10',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Daily LDDS #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '38.60',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Hourly LDDS #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.55',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Daily LDDS #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '37.50',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Hourly LDDS #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.55',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Daily LDDS #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '36.40',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Hourly LDDS #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '6.10',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Daily LDDS #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '35.30',
        quality_rating: 'step_four'
      )

      # step_five FCCHI LDDS
      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Hourly LDDS #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '6.40',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Daily LDDS #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '40.55',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Hourly LDDS #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.80',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Daily LDDS #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '39.40',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Hourly LDDS #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '5.80',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Daily LDDS #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '38.20',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Hourly LDDS #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '6.40',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Daily LDDS #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'LDDS',
        amount: '37.05',
        quality_rating: 'step_five'
      )
    end

    # LDDS Licensed Centers LDDS step_three
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS accredited Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.40',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS accredited Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '57.75',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS accredited Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.05',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '52.50',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.35',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '47.25',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '6.85',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS accredited Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '42.00',
      quality_rating: 'step_three'
    )

    # LDDS Licensed Centers LDDS step_four
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.85',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '60.65',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.45',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '55.15',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.75',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '49.65',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.20',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '44.10',
      quality_rating: 'step_four'
    )

    # LDDS Licensed Centers LDDS step_five
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LDDS Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '9.30',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LDDS Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '63.70',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LDDS Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.90',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LDDS Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '57.90',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LDDS Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '8.10',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LDDS Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '52.10',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LDDS Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '7.55',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LDDS Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'LDDS',
      amount: '46.35',
      quality_rating: 'step_five'
    )

    # License Exempt LD
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly LD License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily LD License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Lancaster-Dakota',
      amount: '13.50'
    )

    # License Exempt DS
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly DS License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '2.25'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily DS License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Douglas-Sarpy',
      amount: '15.00'
    )

    { FCCHI: 'family_child_care_home_i', FCCHII: 'family_child_care_home_ii' }.each do |abbr, license_type|
      %w[step_one step_two not_rated].each do |rating|
        # Other County FCCHI
        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Infant Hourly Other county #{abbr} #{rating}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '3.45',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Infant Daily Other county #{abbr} #{rating}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '30.00',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Toddler Hourly Other county #{abbr} #{rating}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '3.25',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Toddler Daily Other county #{abbr} #{rating}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '28.00',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Preschool Hourly Other county #{abbr} #{rating}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '3.25',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "Preschool Daily Other county #{abbr} #{rating}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '27.00',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "School_Age Hourly Other county #{abbr} #{rating}",
          rate_type: 'hourly',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '3.45',
          quality_rating: rating
        )

        NebraskaRate.find_or_create_by!(
          effective_on: '2022-07-01',
          name: "School_Age Daily Other county #{abbr} #{rating}",
          rate_type: 'daily',
          license_type: license_type,
          max_age: 18,
          region: 'Other',
          amount: '26.25',
          quality_rating: rating
        )
      end

      # Other County FCCHI and FCCHII step_three
      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Hourly Other county #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.65',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Daily Other county #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '31.50',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Hourly Other county #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.45',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Daily Other county #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '29.40',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Hourly Other county #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.45',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Daily Other county #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '28.35',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Hourly Other county #{abbr} step_three",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.65',
        quality_rating: 'step_three'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Daily Other county #{abbr} step_three",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '27.60',
        quality_rating: 'step_three'
      )

      # Other County FCCHI and FCCHII step_four
      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Hourly Other county #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.80',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Daily Other county #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '33.10',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Hourly Other county #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.60',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Daily Other county #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '30.90',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Hourly Other county #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.60',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Daily Other county #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '29.80',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Hourly Other county #{abbr} step_four",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.80',
        quality_rating: 'step_four'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Daily Other county #{abbr} step_four",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '28.95',
        quality_rating: 'step_four'
      )

      # Other County FCCHI and FCCHII step_five
      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Hourly Other county #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '4.00',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Infant Daily Other county #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '34.75',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Hourly Other county #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.80',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Toddler Daily Other county #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '32.45',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Hourly Other county #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '3.80',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "Preschool Daily Other county #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '31.30',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Hourly Other county #{abbr} step_five",
        rate_type: 'hourly',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '4.00',
        quality_rating: 'step_five'
      )

      NebraskaRate.find_or_create_by!(
        effective_on: '2022-07-01',
        name: "School_Age Daily Other county #{abbr} step_five",
        rate_type: 'daily',
        license_type: license_type,
        max_age: 18,
        region: 'Other',
        amount: '30.40',
        quality_rating: 'step_five'
      )
    end

    # Other County Licensed Centers step_three
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly Other county Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.25',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily Other county Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '38.15',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly Other county Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.25',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily Other county Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '36.75',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly Other county Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.25',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily Other county Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '33.90',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly Other county Licensed Center step_three',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.00',
      quality_rating: 'step_three'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily Other county Licensed Center step_three',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '33.60',
      quality_rating: 'step_three'
    )

    # Other County Licensed Centers step_four
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly Other county Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.55',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily Other county Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '40.05',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly Other county Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.55',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily Other county Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '38.60',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly Other county Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.55',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily Other county Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '35.60',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly Other county Licensed Center step_four',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.25',
      quality_rating: 'step_four'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily Other county Licensed Center step_four',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '35.30',
      quality_rating: 'step_four'
    )

    # Other County Licensed Centers step_five
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly Other county Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.80',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily Other county Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '42.05',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly Other county Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.80',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily Other county Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '40.55',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly Other county Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.80',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily Other county Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '37.35',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly Other county Licensed Center step_five',
      rate_type: 'hourly',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '5.50',
      quality_rating: 'step_five'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily Other county Licensed Center step_five',
      rate_type: 'daily',
      license_type: 'licensed_center',
      max_age: 18,
      region: 'Other',
      amount: '37.05',
      quality_rating: 'step_five'
    )

    # Other County License Exempt Home
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly Other county License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '2.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Daily Other county License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '13.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly Other county License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '2.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Daily Other county License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '13.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly Other county License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '2.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Daily Other county License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '13.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly Other county License Exempt Home',
      rate_type: 'hourly',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '2.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Daily Other county License Exempt Home',
      rate_type: 'daily',
      license_type: 'license_exempt_home',
      max_age: 18,
      region: 'Other',
      amount: '13.00'
    )

    # All Counties License Exempt Family In-Home
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Infant Hourly License Exempt Family In-Home',
      rate_type: 'hourly',
      license_type: 'family_in_home',
      max_age: 18,
      region: 'All',
      amount: '9.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Toddler Hourly License Exempt Family In-Home',
      rate_type: 'hourly',
      license_type: 'family_in_home',
      max_age: 18,
      region: 'All',
      amount: '9.00'
    )

    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'Preschool Hourly License Exempt Family In-Home',
      rate_type: 'hourly',
      license_type: 'family_in_home',
      max_age: 18,
      region: 'All',
      amount: '9.00'
    )
    NebraskaRate.find_or_create_by!(
      effective_on: '2022-07-01',
      name: 'School_Age Hourly License Exempt Family In-Home',
      rate_type: 'hourly',
      license_type: 'family_in_home',
      max_age: 18,
      region: 'All',
      amount: '9.00'
    )
  end
end
