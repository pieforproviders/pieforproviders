# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotAttendingPeriod do
  describe 'associations' do
    it { is_expected.to belong_to(:child) }
  end

  describe 'validations' do
    subject { create(:not_attending_period) }

    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    context 'when end date after start date' do
      it 'is valid when end_date is after start_date' do
        period = build(:not_attending_period, start_date: Time.zone.now, end_date: Date.tomorrow)
        expect(period).to be_valid
      end

      it 'is invalid when end_date is before start_date' do
        period = build(:not_attending_period, start_date: Time.zone.now, end_date: Date.yesterday)
        expect(period).not_to be_valid
        expect(period.errors[:end_date]).to include('must be after the start date')
      end
    end
  end

  describe '#currently_active' do
    let(:period) { build(:not_attending_period, start_date:, end_date:) }

    context 'when the period includes today' do
      let(:start_date) { 1.day.ago }
      let(:end_date) { 1.day.from_now }

      it 'returns true' do
        expect(period.active?).to be true
      end
    end

    context 'when the period does not include today' do
      let(:start_date) { 1.day.from_now }
      let(:end_date) { 2.days.from_now }

      it 'returns false' do
        expect(period.active?).to be false
      end
    end
  end
end

# == Schema Information
#
# Table name: not_attending_periods
#
#  id         :uuid             not null, primary key
#  end_date   :date
#  start_date :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :uuid             not null
#
# Indexes
#
#  index_not_attending_periods_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
