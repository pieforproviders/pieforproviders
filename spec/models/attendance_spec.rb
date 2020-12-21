# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  it { should belong_to(:child_approval) }

  it 'calculates the total_time_in_care before validation' do
    attend = create(:attendance, child_approval: create(:child_approval))
    expect(attend).to be_valid
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                                                             :uuid             not null, primary key
#  check_in                                                       :datetime         not null
#  check_out                                                      :datetime         not null
#  total_time_in_care(Calculated: check_out time - check_in time) :interval         not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  child_approval_id                                              :uuid             not null
#
# Indexes
#
#  index_attendances_on_child_approval_id  (child_approval_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_approval_id => child_approvals.id)
#
