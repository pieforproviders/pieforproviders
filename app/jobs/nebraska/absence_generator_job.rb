# frozen_string_literal: true

module Nebraska
  # Job to call Nebraska Absence Generator - for use in daily task and onboarding
  class AbsenceGeneratorJob < ApplicationJob
    def perform(child:, date: nil)
      return unless child

      Nebraska::AbsenceGenerator.new(child:, date:).call
    end
  end
end
