# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:confirmed_user) }

  let(:user) { create(:confirmed_user, phone_number: '888-888-8888') }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
  it { is_expected.to validate_presence_of(:full_name) }
  it { is_expected.to validate_presence_of(:greeting_name) }
  it { is_expected.to validate_presence_of(:language) }
  it { is_expected.to validate_presence_of(:organization) }
  it { is_expected.to validate_uniqueness_of(:phone_number).ignoring_case_sensitivity }
  it { is_expected.to validate_presence_of(:timezone) }
  it { is_expected.to validate_presence_of(:service_agreement_accepted) }
  it { is_expected.to validate_presence_of(:state) }

  it 'factory should be valid (default; no args)' do
    expect(build(:confirmed_user)).to be_valid
    expect(build(:unconfirmed_user)).to be_valid
    expect(build(:admin)).to be_valid
  end

  it 'validates that survey questions are a permitted value only' do
    user.save!

    user.accept_more_subsidy_families = 'True'
    user.valid?
    expect(user.errors.messages).to eq({})
    expect(user).to be_valid

    user.accept_more_subsidy_families = 'not a valid answer'
    user.valid?
    expect(user.errors.messages.keys).to eq([:accept_more_subsidy_families])
    expect(user.errors.messages[:accept_more_subsidy_families]).to include('is not included in the list')
  end

  it 'formats a phone number with non-digit characters' do
    expect(user.phone_number).to eq('8888888888')
  end

  it "doesn't include admin info about a user when returned in json" do
    expect(user.as_json.keys).not_to include('admin')
  end

  describe '#first_approval_effective_date' do
    let!(:business) { create(:business, user: user) }

    before do
      create_list(:child, 3, business: business)
    end

    it 'returns the correct date' do
      expect(user.first_approval_effective_date).to eq(Approval.all.order(effective_on: :desc).first.effective_on)
    end
  end

  describe '#latest_service_day_in_month' do
    let!(:six_months_ago) { Time.current.in_time_zone(user.timezone).at_beginning_of_month - 6.months }
    let!(:child) do
      create(
        :child,
        business: create(:business, user: user),
        approvals: [create(:approval, effective_on: six_months_ago - 1.month, create_children: false)]
      )
    end
    let!(:first_attendance) do
      create(
        :attendance,
        check_in: six_months_ago + 11.hours,
        child_approval: child.child_approvals.first
      )
    end
    let!(:second_attendance) do
      create(
        :attendance,
        check_in: six_months_ago + 2.days + 12.hours,
        child_approval: first_attendance.child_approval
      )
    end
    let!(:third_attendance) do
      create(
        :attendance,
        check_in: Time.current.in_time_zone(user.timezone).at_beginning_of_day + 6.hours,
        child_approval: first_attendance.child_approval
      )
    end

    it 'works without a date passed' do
      expect(user.latest_service_day_in_month(nil)).to eq(third_attendance.service_day.date)
    end

    it 'returns nil for a month without an attendance' do
      expect(
        user.latest_service_day_in_month(
          Time.current.in_time_zone(user.timezone).at_beginning_of_day - 2.months
        )
      ).to be_nil
    end

    it 'returns the latest attendance for a month with multiple attendances' do
      expect(
        user.latest_service_day_in_month(
          Time.current.in_time_zone(user.timezone).at_beginning_of_day - 6.months
        )
      ).to eq(second_attendance.service_day.date)
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                           :uuid             not null, primary key
#  accept_more_subsidy_families :text
#  active                       :boolean          default(TRUE), not null
#  admin                        :boolean          default(FALSE), not null
#  confirmation_sent_at         :datetime
#  confirmation_token           :string
#  confirmed_at                 :datetime
#  current_sign_in_at           :datetime
#  current_sign_in_ip           :inet
#  deleted_at                   :date
#  email                        :string           not null
#  encrypted_password           :string           default(""), not null
#  full_name                    :string           not null
#  get_from_pie                 :text
#  greeting_name                :string           not null
#  language                     :string           not null
#  last_sign_in_at              :datetime
#  last_sign_in_ip              :inet
#  not_as_much_money            :text
#  opt_in_email                 :boolean          default(TRUE), not null
#  opt_in_text                  :boolean          default(TRUE), not null
#  organization                 :string           not null
#  phone_number                 :string
#  phone_type                   :string
#  remember_created_at          :datetime
#  reset_password_sent_at       :datetime
#  reset_password_token         :string
#  service_agreement_accepted   :boolean          default(FALSE), not null
#  sign_in_count                :integer          default(0), not null
#  state                        :string(2)
#  stressed_about_billing       :text
#  timezone                     :string           not null
#  too_much_time                :text
#  unconfirmed_email            :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_phone_number          (phone_number) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token)
#
