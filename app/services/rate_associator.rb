# frozen_string_literal: true

# Service to associate a child with a rate based on their age and
# county where care is received
class RateAssociator
  def initialize(child)
    @child = child
    @region = Illinois::RegionFinder.new(business: child.businesses.find_by(active: true)).call
  end

  def call
    associate_rate
  end

  private

  def associate_rate
    illinois_rate_associator if state == 'IL'
  end

  def county
    @child.businesses.find_by(active: true)&.county
  end

  def state
    @child.businesses.find_by(active: true)&.state
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
