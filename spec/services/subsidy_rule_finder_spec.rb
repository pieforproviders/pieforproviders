# frozen_string_literal: true

require 'rails_helper'
require 'pie_for_providers_error' # TODO: add this to spec_helper.rb ?

# specifications and tests for SubsidyRuleFinder
RSpec.describe SubsidyRuleFinder do

  let(:illinois) { build(:state, name: 'Illinois', abbr: 'IL') }
  let(:cook_county) { build(:county, name: 'Cook', state: illinois) }
  let(:cook_zip_06) { build(:zipcode, county: cook_county, code: '60606') }
  let(:biz) { build(:business, county: cook_county, zipcode: cook_zip_06) }
  let(:kid) { build(:child, date_of_birth: Date.current - 6.years + 20.days,
                    business: biz, approvals: [ build(:approval)]) }

  describe '.for' do

    it 'get the rule based on child age, business state & county and effective_on date' do
      allow(kid).to receive(:age_in_years).and_return(5)
      given_date = Date.current - 2.days
      expect(SubsidyRule).to receive(:age_county_state).with(5, cook_county, illinois, { effective_on: given_date })
                                                       .and_return(true)
      described_class.for(kid, given_date)
    end

    it 'default effective_on is Date.current' do
      allow(kid).to receive(:age_in_years).and_return(5)
      expect(SubsidyRule).to receive(:age_county_state).with(5, cook_county, illinois, { effective_on: Date.current })
                                                       .and_return(true)
      described_class.for(kid)
    end

    it 'gets the age_in_years for the child' do
      allow(SubsidyRule).to receive(:age_county_state).with(5, cook_county, illinois, { effective_on: Date.current })
                                                      .and_return(true)
      expect(kid).to receive(:age_in_years).and_return(5)
      described_class.for(kid)
    end

    it 'raises ItemNotFoundError if it cannot find a SubsidyRule' do
      expect { described_class.for(kid, Date.current - 10.years) }.to raise_error(ItemNotFoundError, /Could not find a SubsidyRule for child/)
    end
  end
end
