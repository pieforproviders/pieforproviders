# frozen_string_literal: true

#--------------------------
#
# @class ChildApprovalFactory
#
# @desc Responsibility: Make a ChildApproval for a child given an approval. Find the SubsidyRule to associate for the given date.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/9/20
#
#--------------------------
class ChildApprovalFactory
  def initialize(child, approval, date: Date.current)
    raise ArgumentError, 'child cannot be nil' if child.nil?
    raise ArgumentError, 'approval cannot be nil' if approval.nil?

    child_approval = ChildApproval.find_or_create_by!(child: child,
                                                      approval: approval,
                                                      subsidy_rule: SubsidyRuleFinder.for(child, date))
    set_child_approval(child, approval, child_approval)
  end

  def set_child_approval(child, approval, child_approval)
    raise "Could not find_or_create_by! a ChildApproval for child #{child.full_name}, approval id #{approval.id}" unless child_approval

    child.child_approvals = [child_approval]
    child_approval
  end
end
