# frozen_string_literal: true

FactoryBot.define do
  factory :child_approval do
    child
    approval

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
#  enrolled_in_school        :boolean
#  full_days                 :integer
#  hours                     :decimal(, )
#  special_needs_daily_rate  :decimal(, )
#  special_needs_hourly_rate :decimal(, )
#  special_needs_rate        :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  approval_id               :uuid             not null
#  child_id                  :uuid             not null
#  illinois_rate_id          :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id       (approval_id)
#  index_child_approvals_on_child_id          (child_id)
#  index_child_approvals_on_illinois_rate_id  (illinois_rate_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (illinois_rate_id => illinois_rates.id)
#
