# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancePolicy do
  subject { described_class }

  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:business) { create(:business, user:) }
  let(:child) { create(:child) }
  let(:admin) { create(:admin) }
  let(:child_approval) { child.child_approvals.first }
  let(:service_day) { create(:service_day, child:) }
  let(:attendance) { create(:attendance, child_approval:, service_day:) }

  before do
    create(:child_business, business:, child:)
  end

  describe AttendancePolicy::Scope do
    context 'when authenticated as an admin' do
      it 'returns all attendances' do
        attendances = described_class.new(admin, Attendance).resolve
        expect(attendances).to contain_exactly(attendance)
      end
    end

    context 'when logged in as an owner user' do
      it 'returns the attendances associated to the user' do
        attendances = described_class.new(user, Attendance).resolve
        expect(attendances).to contain_exactly(attendance)
      end
    end

    context 'when logged in as a non-owner user' do
      it 'returns an empty relation' do
        attendances = described_class.new(non_owner, Attendance).resolve
        expect(attendances).to be_empty
      end
    end
  end
end
