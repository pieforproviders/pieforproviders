# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CaseCycle, type: :model do
  let(:invalid_date_msg) { DateParamValidator.invalid_date_msg }

  it { should belong_to(:user) }

  it { is_expected.to monetize(:copay) }
  it { should validate_numericality_of(:copay).is_greater_than(0) }

  it { should allow_values(:submitted, :pending, :approved, :denied).for(:status) }
  it {
    should define_enum_for(:status).with_values(
      CaseCycle::STATUSES.to_h { |s| [s, s] }
    ).backed_by_column_of_type(:enum)
  }

  it { should allow_values(:submitted, :pending, :approved, :denied).for(:status) }
  it {
    should define_enum_for(:copay_frequency).with_values(
      CaseCycle::COPAY_FREQUENCIES.to_h { |f| [f, f] }
    ).with_suffix.backed_by_column_of_type(:enum)
  }

  it 'factory should be valid (default; no args)' do
    expect(build(:case_cycle)).to be_valid
  end

  it 'validates uniqueness of slug' do
    create(:case_cycle)
    should validate_uniqueness_of(:slug)
  end

  it 'validates submitted_on date if present' do
    cycle = build(:case_cycle, submitted_on: nil)
    expect(cycle).to be_valid

    cycle.submitted_on = 10
    expect(cycle).not_to be_valid
    expect(cycle.errors[:submitted_on]).to include(invalid_date_msg)

    cycle.submitted_on = Time.zone.today
    expect(cycle).to be_valid
  end

  it 'validates effective_on date if present' do
    cycle = build(:case_cycle, effective_on: nil)
    expect(cycle).to be_valid

    cycle.effective_on = 20
    expect(cycle).not_to be_valid
    expect(cycle.errors[:effective_on]).to include(invalid_date_msg)

    cycle.effective_on = Time.zone.today
    expect(cycle).to be_valid
  end

  it 'validates expires_on date if present' do
    cycle = build(:case_cycle, expires_on: nil)
    expect(cycle).to be_valid

    cycle.expires_on = 20
    expect(cycle).not_to be_valid
    expect(cycle.errors[:expires_on]).to include(invalid_date_msg)

    cycle.expires_on = Time.zone.today
    expect(cycle).to be_valid
  end

  it 'validates notified_on date if present' do
    cycle = build(:case_cycle, notified_on: nil)
    expect(cycle).to be_valid

    cycle.notified_on = 10
    expect(cycle).not_to be_valid
    expect(cycle.errors[:notified_on]).to include(invalid_date_msg)

    cycle.notified_on = Time.zone.today
    expect(cycle).to be_valid
  end
end

# == Schema Information
#
# Table name: case_cycles
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer          default(0), not null
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :enum             not null
#  effective_on    :date
#  expires_on      :date
#  notified_on     :date
#  slug            :string           not null
#  status          :enum             default("submitted"), not null
#  submitted_on    :date             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :uuid             not null
#
# Indexes
#
#  index_case_cycles_on_slug     (slug) UNIQUE
#  index_case_cycles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
