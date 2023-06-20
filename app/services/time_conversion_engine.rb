# frozen_string_literal: true

# finds state rule for time in care and state
class TimeConversionEngine
  def initialize(service_day:, state:)
    @service_day = service_day
    @state = state
  end

  def call
    find_state_rule(@service_day, @state)
  end

  private

  def find_state_rule(service_day, state)
    time_in_care = service_day.total_time_in_care
    state_rules = StateTimeRule.where(state: state)
    state_rules.select { |rule| (rule.min_time <= time_in_care.to_i) && (rule.max_time >= time_in_care.to_i) }
  end
end
