# frozen_string_literal: true

require 'pie_for_providers_error'

#--------------------------
#
# @class OnboardingInfoFactory
#
# @desc Responsibility: Given JSON (string) onboarding information, create objects
#   if they don't already exist (e.g. Child, Business, Approval, ChildApproval, etc.)
#   All public methods take a JSON string.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/9/20
#
#--------------------------
class OnboardingInfoFactory

  # Find ()or create if needed) objects in the JSON String that represents onboarding information.
  #  This handles the equivalent of 1 row of an Onboarding CSV file.
  #  TODO: name this to something else? ex: onboarding_json(json) or onboarding_row_json(json) ?
  #
  # Assume that the json data is well formed and complete
  def self.from_json(json)
    business = get_business(json)
    get_child_and_approvals(json, business)
  end

  # Find or Create the business from a JSON string that has a busines name and zip code
  #  If the business is not found, create it.  Set the user to the first admin (User) found.
  #  Raise an error if the zip code is not found.
  #
  # @return [Business]
  # @raise [ItemNotFoundError]
  def self.get_business(json)
    json_hash = json_to_h(json)
    zipcode = Zipcode.find_by(code: json_hash['business_zip_code'])
    raise_not_found_error("Zipcode #{json_hash['business_zip_code']}") unless zipcode

    biz_name = json_hash['business_name']
    business = Business.find_or_create_by!(name: biz_name, zipcode: zipcode) do |biz|
      biz.user = User.find_by(admin: true)
      biz.county = zipcode.county
      biz.active = true
    end
    raise_not_found_error("Business '#{biz_name}'") unless business

    business
  end


  # Create a Child based on the information in the json string and the business.
  # Do nothing if the child already exists.
  #
  # Associate the approval that is described in the json string.
  # Provide the child and approval to the ChildApprovalFactory so that it can create a complete
  # ChildApproval associated with the child.
  #
  def self.get_child_and_approvals(json, business)
    json_hash = json_to_h(json)
    full_name = "#{json_hash['first_name'].strip} #{json_hash['last_name'].strip}"
    dob = Date.parse(json_hash['date_of_birth'])
    return if Child.find_by(full_name: full_name, date_of_birth: dob, business: business)

    new_child = Child.create!(full_name: full_name,
                              date_of_birth: dob,
                              business: business,
                              active: true,
                              approvals: [get_approval(json)])

    ChildApprovalFactory.new(new_child, new_child.approvals.first)
  end

  # Find an Approval based on the case number, effective_on date, and expires_on date
  # in a json String. Raise an error if the Approval doesn't exist.
  #
  # @return [Approval]
  # @raise [ItemNotFoundError]
  def self.get_approval(json)
    json_hash = json_to_h(json)
    approval_data = { case_number: json_hash['case_number'].to_s.strip }
    approval_data['effective_on'] = json_hash['effective_on'] if json_hash['effective_on'].present?
    approval_data['expires_on'] = json_hash['expires_on'] if json_hash['expires_on'].present?
    approval = Approval.find_by(approval_data)
    raise_not_found_error("Approval case number: #{json_hash['case_number']} effective on: #{json_hash['effective_on']} expires on: #{json_hash['expires_on']}") unless approval

    approval
  end

  # @return [Hash] - JSON parsed json string and converted to a Hash
  def self.json_to_h(json)
    JSON.parse(json).to_h
  end

  # Raise the NotFoundError with the info about what wasn't found in the CSV
  # @raise NotFoundError
  def self.raise_not_found_error(not_found_info)
    raise ItemNotFoundError, "#{not_found_info} in the CSV file is not in the db."
  end
end
