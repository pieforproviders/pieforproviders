# frozen_string_literal: true

FactoryBot.define do
  factory :child_site do
    child
    site

    # Random Date, starting 3 years ago
    started_care { Faker::Date.backward(days: (Random.rand(3) * 365).to_i) }
    ended_care { Faker::Date.between(from: started_care, to: Date.current) }
  end
end

# == Schema Information
#
# Table name: child_sites
#
#  id           :uuid             not null, primary key
#  ended_care   :date
#  started_care :date
#  child_id     :uuid             not null
#  site_id      :uuid             not null
#
# Indexes
#
#  index_child_sites_on_child_id_and_site_id  (child_id,site_id)
#
