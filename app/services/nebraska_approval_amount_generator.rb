# frozen_string_literal: true

# Service to create approval amounts when a child is created in NE
class NebraskaApprovalAmountGenerator < ApplicationService
  def initialize(child, params)
    @child = child
    @approval_periods = params[:approval_periods]
    @approval = Approval.find_by(params[:approvals_attributes]&.first)
    @child_approval = child.child_approvals.find_by(approval: @approval)
  end

  def call
    generate_approval_amounts
  end

  private

  def generate_approval_amounts
    @approval_periods.each do |approval_period|
      NebraskaApprovalAmount.find_or_create_by!(
        child_approval: @child_approval,
        effective_on: approval_period[:effective_on],
        expires_on: approval_period[:expires_on],
        family_fee: approval_period[:family_fee],
        allocated_family_fee: approval_period[:allocated_family_fee]
      )
    end
  end
end
