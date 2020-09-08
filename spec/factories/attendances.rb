# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    child_case_cycle
    starts_on { Date.current }
    length_of_care { Attendance::LENGTHS_OF_CARE.sample }
  end
end
