# frozen_string_literal: true

# Service to associate a child with an approval if one with their case number nd effective/expiration date already exists
class CheckIfApprovalExists
  def initialize(child)
    @child = child
  end

  attr_reader :child

  def call
    associate_child_to_approval
  end

  private

  def associate_child_to_approval
    unless approvals_with_case_number
      Approval.create(
        case_number: case_number,
        copay_cents: copay,
        copay_frequency: copay_frequency,
        effective_on: effective_on,
        expires_on: expires_on
      )
    end
    child.approvals.update!()
  end

  def approvals_with_case_number
    @approvals_with_case_number ||= Approval.current.where(case_number: case_number, effective_on: effective_on, expires_on: expires_on)
  end

  def case_numbers
    # grab approval that isn't expired
  end
end
