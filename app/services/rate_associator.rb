# frozen_string_literal: true

# Service to associate a child with a rate based on their age and
# county where care is received
class RateAssociator
  def initialize(child)
    @child = child
    active_business = @child.child_businesses.find_by(currently_active: true)&.business
    @region = Illinois::RegionFinder.new(business: active_business).call
  end

  def call
    associate_rate
  end

  private

  def associate_rate
    illinois_rate_associator if state == 'IL'
  end

  def county
    @child.child_businesses.find_by(currently_active: true)&.business&.county
  end

  def state
    @child.child_businesses.find_by(currently_active: true)&.business&.state
  end

  def today
    Time.current
  end

  def illinois_rate
    IllinoisRate.active_on(today).where('age_bucket >= ?', @child.age).where(region: @region).order(:age_bucket).first
  end

  def illinois_rate_associator
    @child.active_child_approval(today)&.update!(rate: illinois_rate)
  end
end
