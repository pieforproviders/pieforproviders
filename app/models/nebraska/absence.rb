# frozen_string_literal: true

module Nebraska
  # Nebraska's monthly absence limit
  class Absence < Nebraska::Limit
    def reject_frequency(service_days)
      # does a thing
    end

    def reject_amount(service_days)
      # does a thing
    end
  end
end

# == Schema Information
#
# Table name: nebraska_limits
#
#  id         :uuid             not null, primary key
#  amount     :integer          not null
#  effective  :time             not null
#  expires    :time
#  frequency  :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
