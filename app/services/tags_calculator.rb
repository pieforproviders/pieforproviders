# frozen_string_literal: true

# Service to get tags for a given service day
class TagsCalculator
  attr_reader :service_day

  def initialize(service_day:)
    @service_day = service_day
  end

  def call
    build_tags
  end

  private

  def build_tags
    return Nebraska::TagsCalculator.new(service_day: service_day).call if service_day.child.state == 'NE'
    return Illinois::TagsCalculator.new(service_day: service_day).call if service_day.child.state == 'IL'
  end
end
