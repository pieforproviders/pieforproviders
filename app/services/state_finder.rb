# frozen_string_literal: true

# Get State by Zipcode
class StateFinder
  ZIP_RANGES = [
    { start: 35_000, end: 36_999, abbr: 'AL', name: 'Alabama' },
    { start: 99_500, end: 99_999, abbr: 'AK', name: 'Alaska' },
    { start: 85_000, end: 86_999, abbr: 'AZ', name: 'Arizona' },
    { start: 71_600, end: 72_999, abbr: 'AR', name: 'Arkansas' },
    { start: 90_000, end: 96_699, abbr: 'CA', name: 'California' },
    { start: 80_000, end: 81_999, abbr: 'CO', name: 'Colorado' },
    { start: 6000, end: 6999, abbr: 'CT', name: 'Connecticut' },
    { start: 19_700, end: 19_999, abbr: 'DE', name: 'Delaware' },
    { start: 32_000, end: 34_999, abbr: 'FL', name: 'Florida' },
    { start: 30_000, end: 31_999, abbr: 'GA', name: 'Georgia' },
    { start: 96_700, end: 96_999, abbr: 'HI', name: 'Hawaii' },
    { start: 83_200, end: 83_999, abbr: 'ID', name: 'Idaho' },
    { start: 60_000, end: 62_999, abbr: 'IL', name: 'Illinois' },
    { start: 46_000, end: 47_999, abbr: 'IN', name: 'Indiana' },
    { start: 50_000, end: 52_999, abbr: 'IA', name: 'Iowa' },
    { start: 66_000, end: 67_999, abbr: 'KS', name: 'Kansas' },
    { start: 40_000, end: 42_999, abbr: 'KY', name: 'Kentucky' },
    { start: 70_000, end: 71_599, abbr: 'LA', name: 'Louisiana' },
    { start: 3900, end: 4999, abbr: 'ME', name: 'Maine' },
    { start: 20_600, end: 21_999, abbr: 'MD', name: 'Maryland' },
    { start: 1000, end: 2799, abbr: 'MA', name: 'Massachusetts' },
    { start: 48_000, end: 49_999, abbr: 'MI', name: 'Michigan' },
    { start: 55_000, end: 56_999, abbr: 'MN', name: 'Minnesota' },
    { start: 38_600, end: 39_999, abbr: 'MS', name: 'Mississippi' },
    { start: 63_000, end: 65_999, abbr: 'MO', name: 'Missouri' },
    { start: 59_000, end: 59_999, abbr: 'MT', name: 'Montana' },
    { start: 27_000, end: 28_999, abbr: 'NC', name: 'North Carolina' },
    { start: 58_000, end: 58_999, abbr: 'ND', name: 'North Dakota' },
    { start: 68_000, end: 69_999, abbr: 'NE', name: 'Nebraska' },
    { start: 88_900, end: 89_999, abbr: 'NV', name: 'Nevada' },
    { start: 3000, end: 3899, abbr: 'NH', name: 'New Hampshire' },
    { start: 7000, end: 8999, abbr: 'NJ', name: 'New Jersey' },
    { start: 87_000, end: 88_499, abbr: 'NM', name: 'New Mexico' },
    { start: 10_000, end: 14_999, abbr: 'NY', name: 'New York' },
    { start: 43_000, end: 45_999, abbr: 'OH', name: 'Ohio' },
    { start: 73_000, end: 74_999, abbr: 'OK', name: 'Oklahoma' },
    { start: 97_000, end: 97_999, abbr: 'OR', name: 'Oregon' },
    { start: 15_000, end: 19_699, abbr: 'PA', name: 'Pennsylvania' },
    { start: 300, end: 999, abbr: 'PR', name: 'Puerto Rico' },
    { start: 2800, end: 2999, abbr: 'RI', name: 'Rhode Island' },
    { start: 29_000, end: 29_999, abbr: 'SC', name: 'South Carolina' },
    { start: 57_000, end: 57_999, abbr: 'SD', name: 'South Dakota' },
    { start: 37_000, end: 38_599, abbr: 'TN', name: 'Tennessee' },
    { start: 75_000, end: 79_999, abbr: 'TX', name: 'Texas' },
    { start: 88_500, end: 88_599, abbr: 'TX', name: 'Texas' },
    { start: 84_000, end: 84_999, abbr: 'UT', name: 'Utah' },
    { start: 5000, end: 5999, abbr: 'VT', name: 'Vermont' },
    { start: 22_000, end: 24_699, abbr: 'VA', name: 'Virgina' },
    { start: 20_000, end: 20_599, abbr: 'DC', name: 'Washington DC' },
    { start: 98_000, end: 99_499, abbr: 'WA', name: 'Washington' },
    { start: 24_700, end: 26_999, abbr: 'WV', name: 'West Virginia' },
    { start: 53_000, end: 54_999, abbr: 'WI', name: 'Wisconsin' },
    { start: 82_000, end: 83_199, abbr: 'WY', name: 'Wyoming' }
  ].freeze

  def initialize(business)
    @business = business
    @zipcode = business.zipcode
  end

  def call
    # Ensure param is a string to prevent unpredictable parsing results
    return unless @zipcode.is_a?(String)

    # Ensure we have exactly 5 characters to parse
    return unless @zipcode.size == 5

    # Ensure we don't parse strings starting with 0 as octal values
    zip_integer = Integer(@zipcode, 10)

    state = ZIP_RANGES.find { |range| zip_integer.between?(range[:start], range[:end]) }

    # update_column doesn't trigger callbacks, so this prevents the infinite loop

    # rubocop:disable Rails/SkipsModelValidations
    @business.update_column(:state, state[:abbr])
    # rubocop:enable Rails/SkipsModelValidations
  end
end
