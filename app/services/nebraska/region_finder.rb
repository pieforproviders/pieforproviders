# frozen_string_literal: true

module Nebraska
  # Service to generate absences, to be scheduled daily
  class RegionFinder
    attr_reader :business

    def initialize(business:)
      @business = business
    end

    def call
      region
    end

    private

    # rubocop:disable Metrics/MethodLength
    def region
      if business.license_type == 'license_exempt_home'
        if %w[Lancaster Dakota].include?(business.county)
          'Lancaster-Dakota'
        elsif %(Douglas Sarpy).include?(business.county)
          'Douglas-Sarpy'
        else
          'Other'
        end
      elsif business.license_type == 'family_in_home'
        'All'
      else
        %w[Lancaster Dakota Douglas Sarpy].include?(business.county) ? 'LDDS' : 'Other'
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
