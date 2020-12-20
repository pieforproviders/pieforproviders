# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    child_approval

    check_in { Faker::Time.between(from: DateTime.now.at_beginning_of_month, to: DateTime.now) }
    check_out { check_in + rand(0..23).hours + rand(0..59).minutes }
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                             :uuid             not null, primary key
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime         not null
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  child_approval_id                                              :uuid             not null
#
# Indexes
#
#  index_attendances_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
