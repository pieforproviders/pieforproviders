# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceDayPolicy do
  subject { described_class }

  let(:user) { create(:confirmed_user) }
  let(:non_owner) { create(:confirmed_user) }
  let(:business) { create(:business, :nebraska_ldds, user: user) }
  let(:admin) { create(:admin) }
  let(:child) { create(:child, business: business) }
  let(:child_approval) { child.child_approvals.first }
  let(:attendance) { create(:attendance, child_approval: child_approval) }
  let(:service_day) { attendance.service_day }

  describe ServiceDayPolicy::Scope do
    context 'when authenticated as an admin' do
      it 'returns all service_days' do
        service_days = described_class.new(admin, ServiceDay).resolve
        expect(service_days).to match_array([service_day])
      end
    end

    context 'when logged in as an owner user' do
      it 'returns the service_days associated to the user' do
        service_days = described_class.new(user, ServiceDay).resolve
        expect(service_days).to match_array([service_day])
      end
    end

    context 'when logged in as a non-owner user' do
      it 'returns an empty relation' do
        service_days = described_class.new(non_owner, ServiceDay).resolve
        expect(service_days).to be_empty
      end
    end
  end
end
