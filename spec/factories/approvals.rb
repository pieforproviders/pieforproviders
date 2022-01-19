# frozen_string_literal: true

FactoryBot.define do
  factory :approval do
    case_number { Faker::Number.number(digits: 10) }
    copay_cents { Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000) }
    copay_frequency { copay ? Copays.frequencies.keys.sample : nil }
    effective_on { 9.months.ago.to_date }
    expires_on { effective_on + 1.year }

    transient do
      create_children { true }
      num_children { rand(1..3) }
      nebraska { true }
      business { nil }
    end

    # unless create_children is set to false, if we create an approval,
    # this will create N number of children to belong to that approval
    after(:create) do |approval, evaluator|
      if evaluator.create_children
        business = evaluator.business || (evaluator.nebraska ? create(:business, :nebraska_ldds) : create(:business))
        create_list(:child, evaluator.num_children, business: business, approvals: [approval])
      end
      approval.child_approvals.each do |child_approval|
        child_approval.update!(attributes_for(:child_approval))
      end
    end

    factory :expired_approval do
      effective_on { 3.years.ago.to_date }
      expires_on { 2.years.ago.to_date }
    end
  end
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  active          :boolean          default(TRUE), not null
#  case_number     :string
#  copay_cents     :integer
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :string
#  deleted_at      :date
#  effective_on    :date
#  expires_on      :date
#  inactive_reason :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_approvals_on_effective_on  (effective_on)
#  index_approvals_on_expires_on    (expires_on)
#
