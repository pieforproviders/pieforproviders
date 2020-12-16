# frozen_string_literal: true

# Service to associate a child with an approval if one with their case number and effective/expiration date already exists
class ApprovalAssociator
  def initialize(child)
    @child = child
  end

  attr_reader :child

  def call
    associate_child_to_approval
  end

  private

  def potential_approval
    child.approvals.first
  end

  def matching_approval
    @matching_approval ||= Approval.current.where(case_number: potential_approval.case_number, effective_on: potential_approval.effective_on, expires_on: potential_approval.expires_on).first
  end

  def create_approval
    Approval.new(
      case_number: potential_approval.case_number,
      copay_cents: potential_approval.copay,
      copay_frequency: potential_approval.copay_frequency,
      effective_on: potential_approval.effective_on,
      expires_on: potential_approval.expires_on
    )
  end

  def associate_child_to_approval
    return unless matching_approval

    child.approvals.clear
    child.approvals << matching_approval #|| create_approval
  end
end
