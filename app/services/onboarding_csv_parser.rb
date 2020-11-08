# frozen_string_literal: true

require 'csv'

# Error raised if an object in the CSV is not found in the db
class ItemNotFoundError < StandardError; end

#--------------------------
#
# @class OnboardingCsvParser
#
# @desc Responsibility: Parse the CSV IO given. Create
#   objects as needed if they don't already exist.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/01/20
#
#--------------------------
#
class OnboardingCsvParser
  DATE_FORMAT = '%m-%d-%Y'
  CONVERTERS = %i[numeric date].freeze

  # ----------------------------------------------------------------------

  def self.parse(data_string)
    csv_rows = CSV.parse(data_string,
                         headers: true,
                         return_headers: false,
                         unconverted_fields: %i[business_zip_code],
                         converters: CONVERTERS)

    csv_rows.each do |row|
      business = get_business(row)
      import_child_and_related(row, business)
    end
  end

  # Get the business from the db. Raise error if the business is not found.
  # @raise ItemNotFoundError
  def self.get_business(row)
    zipcode = Zipcode.find_by(code: row['business_zip_code'].to_s)
    raise_not_found_error("Zipcode #{row['business_zip_code']}") unless zipcode

    biz_name = row['business_name'].strip
    business = Business.find_by(name: biz_name, zipcode: zipcode)
    raise_not_found_error("Business '#{biz_name}'") unless business

    business
  end

  # Create the child if it doesn't already exist and then create the ChildApproval for it
  def self.import_child_and_related(row, business)
    full_name = "#{row['first_name'].strip} #{row['last_name'].strip}"
    dob = row['date_of_birth']
    return if Child.find_by(full_name: full_name, date_of_birth: dob, business: business)

    new_child = Child.create!(full_name: full_name,
                              date_of_birth: dob,
                              business: business,
                              active: true,
                              approvals: [get_approval(row)])

    create_child_approval(new_child, new_child.approvals.first)
  end

  def self.get_approval(row)
    approval_data = { case_number: row['case_number'].to_s }
    approval_data[:effective_on] = row['effective_on'] if row['effective_on'].present?
    approval_data[:expires_on] = row['expires_on'] if row['expires_on'].present?
    approval = Approval.find_by(approval_data)
    raise_not_found_error("Approval case number: #{row['case_number']} effective on: #{row['effective_on']} expires on: #{row['expires_on']}") unless approval

    approval
  end

  def self.create_child_approval(child, approval)
    child_subsidy_rule = get_subsidy_rule(child.age_in_years,
                                          child.business.county,
                                          child.business.county.state,
                                          effective_on: Date.current)

    child_approval = ChildApproval.find_or_create_by!(child: child,
                                                      approval: approval,
                                                      subsidy_rule: child_subsidy_rule)
    child.child_approvals = [child_approval]
  end

  # @return [SubsidyRule | nil] - get the subsidy rule that applies for a
  #   (child's) age and location (county and state) and is effective on
  #   the given effective_on date.
  def self.get_subsidy_rule(age, county, state, effective_on: Date.current)
    SubsidyRule.age_county_state(age, county, state, effective_on: effective_on)
  end

  # Raise the NotFoundError with the info about what wasn't found in the CSV
  # @raise NotFoundError
  def self.raise_not_found_error(not_found_info)
    raise ItemNotFoundError, "#{not_found_info} in the CSV file is not in the db."
  end
end
