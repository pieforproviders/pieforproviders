# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationGenerator, type: :service do
  let!(:expired_approval) { create(:approval, num_children: 3, expires_on: 1.day.before) }
  let!(:expired_children) { expired_approval.children }

  describe '#call' do
    context 'when there are only expired approvals' do
      it 'does not create any notifications' do
        expect { described_class.new.call }.not_to change(Notification, :count)
      end
    end

    context 'when there are both valid approvals and expired approvals' do
      before { create(:approval, num_children: 3, expires_on: 20.days.after) }

      it 'creates only notifications for valid approvals' do
        expect { described_class.new.call }.to change(Notification, :count).from(0).to(3)
      end
    end

    context 'when there is an expired notification' do
      before do
        create(:notification, child: expired_children.first, approval: expired_approval)
      end

      it 'clears expired notifications' do
        expect { described_class.new.call }.to change(Notification, :count).from(1).to(0)
      end
    end

    context 'when there is an expired notification and valid notifications' do
      before do
        create(:notification, child: expired_children.first, approval: expired_approval)
        create(:approval, num_children: 3, expires_on: 20.days.after)
      end

      it 'clears expired notifications and generates new notifications' do
        expect { described_class.new.call }.to change(Notification, :count).from(1).to(3)
      end
    end

    context 'when there is a depreciated approval and an updated approval' do
      before do
        valid = create(:approval, num_children: 1, expires_on: 20.days.after)
        create(:approval,
               create_children: false,
               children: [valid.children.first],
               expires_on: 365.days.after,
               effective_on: 21.days.after)
      end

      it 'doesn\'t create a new notification' do
        expect { described_class.new.call }.not_to change(Notification, :count)
      end
    end

    context 'when a valid approval for notification has been updated to a year later' do
      before do
        valid = create(:approval, num_children: 1, expires_on: 20.days.after)
        create(:notification, child: valid.children.first, approval: valid)
        create(:approval,
               create_children: false,
               children: [valid.children.first],
               expires_on: 365.days.after,
               effective_on: 21.days.after)
      end

      it 'removes the notification' do
        expect { described_class.new.call }.to change(Notification, :count).from(1).to(0)
      end
    end
  end
end
