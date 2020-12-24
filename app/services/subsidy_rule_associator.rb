# frozen_string_literal: true

# Service to associate a child with a subsidy rule based on their age and
# county where care is received
class SubsidyRuleAssociator
  def initialize(child)
    @child = child
    @county = child.business.county
    @state = child.business.state
  end

  def call
    associate_subsidy_rule
  end

  private

  def associate_subsidy_rule
    illinois_subsidy_rule_associator if @state == 'IL'
  end

  def age
    dob = @child.date_of_birth
    years_since_birth = Date.current.year - dob.year
    birthday_passed = dob.month >= Date.current.month && dob.day >= Date.current.day
    birthday_passed ? years_since_birth : years_since_birth - 1
  end

  def illinois_subsidy_rule_associator
    subsidy_rule = SubsidyRule.current.where('max_age >= ?', age).where(county: @county).order(:max_age).first
    @child.current_child_approval.update!(subsidy_rule: subsidy_rule)
  end
end
