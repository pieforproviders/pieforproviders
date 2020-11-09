# frozen_string_literal: true

#--------------------------
#
# @class SubsidyRuleFinder
#
# @desc Responsibility: find a subsidy rule for a child of a given age, and is effective on the given date.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/9/20
#
class SubsidyRuleFinder

  # @return [SubsidyRule | nil] - get the subsidy rule that applies for a
  #   (child's) age and location (county and state) and is effective on
  #   the given effective_on date.
  # @raise NotFoundError - if a SubsidyRule cannot be found
  def self.for(child, date = Date.current)
      age = child.age_in_years
      county = child.business.county
      state = child.business.county.state
      subsidy_rule = SubsidyRule.age_county_state(age, county, state, effective_on: date)
      raise ItemNotFoundError, "Could not find a SubsidyRule for child #{child.full_name}, date: #{date} in #{county.name} county, #{state.name}" unless subsidy_rule

      subsidy_rule
  end
end
