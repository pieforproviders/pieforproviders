# frozen_string_literal: true

FactoryBot.define do
  factory :child_approval do
    child
    approval
    full_days { rand(0..30) }
    hours { rand(0..120) }
    special_needs_rate { Faker::Boolean.boolean }
    special_needs_daily_rate { special_needs_rate ? rand(0.0..20).round(2) : nil }
    special_needs_hourly_rate { special_needs_rate ? rand(0.0..10).round(2) : nil }
    enrolled_in_school { false }
    authorized_weekly_hours { rand(0..45) }

    factory :child_approval_with_attendances do
      after :create do |child_approval|
        create_list(:attendance, 3, child_approval: child_approval)
      end
    end
  end
end

# == Schema Information
#
# Table name: child_approvals
#
#  id                        :uuid             not null, primary key
#  authorized_weekly_hours   :integer
#  enrolled_in_school        :boolean
#  full_days                 :integer
#  hours                     :decimal(, )
#  rate_type                 :string
#  special_needs_daily_rate  :decimal(, )
#  special_needs_hourly_rate :decimal(, )
#  special_needs_rate        :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  approval_id               :uuid             not null
#  child_id                  :uuid             not null
#  rate_id                   :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id  (approval_id)
#  index_child_approvals_on_child_id     (child_id)
#  index_child_approvals_on_rate         (rate_type,rate_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#
