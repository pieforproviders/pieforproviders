# frozen_string_literal: true

# Quality ratings of businesses, that impact which rate is applied
module QualityRatings
  extend ActiveSupport::Concern

  TYPES = %w[
    not_rated
    step_one
    step_two
    step_three
    step_four
    step_five
    gold
    silver
    bronze
  ].freeze

  included do
    validates :quality_rating, inclusion: { in: TYPES }, allow_nil: true
  end
end
