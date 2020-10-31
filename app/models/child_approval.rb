# frozen_string_literal: true

# An individual child on a family's approval letter
class ChildApproval < UuidApplicationRecord
  belongs_to :child
  belongs_to :approval
  belongs_to :subsidy_rule, optional: true
  has_many :child_approval_rate_types, dependent: :destroy
  has_many :rate_types, through: :child_approval_rate_types

  before_save :associate_subsidy_rule

  delegate :user, to: :child

  private

  def associate_subsidy_rule
    case state
    when 'Illinois'
      # associate the child with the appropriate Illinois subsidy rule
      self.subsidy_rule = SubsidyRule.where(state: state, county: county).find_by('max_age >= ? AND effective_on < ? AND expires_on >= ?', age, Time.zone.today, Time.zone.today)
    when 'Nebraska'
      # associate the child with the appropriate Nebraska subsidy rule
    end
  end
end

def state
  child.business.state
end

def county
  child.business.county
end

def age
  ((Time.zone.today - child.date_of_birth) / 365.25).to_f.round(2)
end

# == Schema Information
#
# Table name: child_approvals
#
#  id              :uuid             not null, primary key
#  approval_id     :uuid             not null
#  child_id        :uuid             not null
#  subsidy_rule_id :uuid
#
# Indexes
#
#  index_child_approvals_on_approval_id      (approval_id)
#  index_child_approvals_on_child_id         (child_id)
#  index_child_approvals_on_subsidy_rule_id  (subsidy_rule_id)
#
# Foreign Keys
#
#  fk_rails_...  (approval_id => approvals.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (subsidy_rule_id => subsidy_rules.id)
#
