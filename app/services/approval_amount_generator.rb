# frozen_string_literal: true

# Service to create approval amounts when a child is created
class ApprovalAmountGenerator
  def initialize(child, month_amounts, first_month, year)
    @child = child
    @state = @child.business.state
    @child_approval = @child.child_approvals.first
    @month_amounts = month_amounts
    @first_month = first_month
    @year = year
  end

  def call
    generate_approval_amounts
  end

  private

  def generate_approval_amounts
    illinois_approval_amount_generator if @state == 'IL'
  end

  def illinois_approval_amount_generator
    prep_single_month_amounts
    @month_amounts.each do |month, approved_days|
      index = month.to_s.delete('month').to_i - 1
      create_illinois_approval_amount(approved_days, index)
    end
  end

  def prep_single_month_amounts
    return unless @month_amounts.keys.length == 1

    11.times do
      key = @month_amounts.keys.last.to_s.delete('month').to_i + 1
      @month_amounts.merge!({ "month#{key}": @month_amounts['month1'] })
    end
  end

  def create_illinois_approval_amount(approved_days, index)
    IllinoisApprovalAmount.create!(
      child_approval: @child_approval,
      month: Date.parse("#{@first_month} #{@year}") + index.months,
      part_days_approved_per_week: approved_days['part_days_approved_per_week'],
      full_days_approved_per_week: approved_days['full_days_approved_per_week']
    )
  end
end
