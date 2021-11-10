# frozen_string_literal: true

module Nebraska
  # limits as set out by the state
  class Limit < UuidApplicationRecord
    validates :amount, presence: true
    validates :effective, time_param: true, presence: true
    validates :expires, time_param: true, unless: proc { |attendance| attendance.check_out_before_type_cast.nil? }
    validates :frequency, presence: true
    validates :type, presence: true
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
