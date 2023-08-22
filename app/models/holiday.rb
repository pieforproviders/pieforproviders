# frozen_string_literal: true

# The federal holidays
class Holiday < UuidApplicationRecord
end

# == Schema Information
#
# Table name: holidays
#
#  id         :uuid             not null, primary key
#  date       :date
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  unique_holiday  (name,date) UNIQUE
#
