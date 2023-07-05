# frozen_string_literal: true

namespace :db do
  desc 'Populate the database with sample data'
  task populate_state_time_rules: :environment do
    states = [
      { name: 'Nebraska', code: 'NE', subsidy_type: 'Type 1' },
      { name: 'Illinois', code: 'IL', subsidy_type: 'Type 2' }
    ]

    state = states.select { |item| item[:name] == 'Nebraska' }

    created_state = State.create!(state.first)

    puts "Created state: #{created_state.name}"

    StateTimeRule.create!(
      name: "Partial Day #{created_state.name}",
      state: created_state,
      min_time: 60, # 1minute
      max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
    )
    StateTimeRule.create!(
      name: "Full Day #{created_state.name}",
      state: created_state,
      min_time: 5 * 3600, # 5 hours
      max_time: (10 * 3600) # 10 hours
    )
    StateTimeRule.create!(
      name: "Full - Partial Day #{created_state.name}",
      state: created_state,
      min_time: (10 * 3600) + 60, # 10 hours and 1 minute
      max_time: (18 * 3600) # 18 hours
    )
  end
end
