# frozen_string_literal: true

# Service to associate a child with an approval if one with their case number nd effective/expiration date already exists
class CheckIfApprovalExists
  def initialize(child:, case_number:, effective_on:, expires_on:)
    @child = child
    @case_number = case_number
    @effective_on = effective_on
    @expires_on = expires_on
  end

  attr_reader :child, :case_number, :effective_on, :expires_on

  def call
    associate_child_to_approval
  end

  private

  def associate_child_to_approval
    'create approval' unless approvals_with_case_number
    # what is needed to create an approval?
  end

  def approvals_with_case_number
    @approvals_with_case_number ||= Approval.current.where(case_number: case_number, effective_on: effective_on, expires_on: expires_on)
  end
end
