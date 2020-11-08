# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateHelperService, type: :service do
  describe '.leap_day_btwn?' do
    it 'no leap day between the dates' do
      expect(described_class.leap_day_btwn?(Date.new(2019, 2, 27), Date.new(2019, 3, 1)))
        .to be_falsey
    end
    it 'leap day is between the dates' do
      expect(described_class.leap_day_btwn?(Date.new(2020, 2, 27), Date.new(2020, 3, 1)))
        .to be_truthy
    end
    it 'earlier date is a leap day' do
      expect(described_class.leap_day_btwn?(Date.new(2020, 2, 29), Date.new(2020, 3, 1)))
        .to be_truthy
    end
    it 'later date is a leap day' do
      expect(described_class.leap_day_btwn?(Date.new(2020, 2, 27), Date.new(2020, 2, 29)))
        .to be_truthy
    end
  end

  describe '.recent_leap_day' do
    context 'day is in a leap year' do
      it 'returns the leap day in that year' do
        expect(described_class.recent_leap_day(Date.new(2020, 3, 1)))
          .to eq(Date.new(2020, 2, 29))
      end
    end

    context 'day is not in a leap year' do
      it 'returns the leap day in the most recent leap year' do
        expect(described_class.recent_leap_day(Date.new(2019, 3, 1)))
          .to eq(Date.new(2016, 2, 29))
      end
    end
  end
end
