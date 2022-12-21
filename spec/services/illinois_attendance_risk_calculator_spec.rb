# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisAttendanceRiskCalculator, type: :service do
  describe '#elapsed_eligible_days' do 
    it 'calculate elapsed eligible days for child with attended info' do
      business = create(:business)
      child = create(:child_in_illinois, business: business)
      date = Date.new(2022, 12, 20)
      elapsed_days = 19
      weekend_days = 6
      # binding.pry
      risk_calculator_elapsed_days = described_class.new(child, date).send(:elapsed_eligible_days)
      expect(risk_calculator_elapsed_days).to eq(elapsed_days - weekend_days)
    end

    it 'calculate elapsed eligible days when business has closures' do
      business = create(:business_with_closed_days_in_november)
      child = create(:child_in_illinois, business: business)
      date = Date.new(2022, 11, 22)
      risk_calculator_elapsed_days = described_class.new(child, date).send(:elapsed_eligible_days)
      binding.pry
    end
  end
end
