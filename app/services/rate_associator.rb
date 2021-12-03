# frozen_string_literal: true

# Service to associate a child with a rate based on their age and
# county where care is received
class RateAssociator
  def initialize(child)
    @child = child
  end

  def call
    associate_rate
  end

  private

  def associate_rate
    illinois_rate_associator if state == 'IL'
  end

  def county
    @child.business.county
  end

  def state
    @child.business.state
  end

  def today
    Time.current
  end

  def illinois_rate
    IllinoisRate.active_on(today).where('max_age >= ?', @child.age).where(county: county).order(:max_age).first
  end

  def illinois_rate_associator
    @child.active_child_approval(today).update!(rate: illinois_rate)
  end
end
