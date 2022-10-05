# frozen_string_literal: true

module Illinois
  # Service to find the region in Illinois where a business is located
  # for rate calculation.
  class RegionFinder
    attr_reader :business

    GROUP_1A = %w[Cook DeKalb DuPage Kane Kendall Lake McHenry].freeze
    GROUP_2A = ['Boone',
                'Champaign',
                'Kankakee',
                'Madison',
                'McLean',
                'Monroe',
                'Ogle',
                'Peoria',
                'Rock Island',
                'Sangamon',
                'St. Clair',
                'Tazewell',
                'Whiteside',
                'Will',
                'Winnebago',
                'Woodford'].freeze

    def initialize(business:)
      @business = business
    end

    def call
      region
    end

    private

    def region
      if %w[license_exempt_day_care_center in_home].include?(business.license_type)
        'all'
      elsif GROUP_1A.include?(business.county)
        'group_1a'
      elsif GROUP_2A.include?(business.county)
        'group_1b'
      else
        'group_2'
      end
    end
  end
end
