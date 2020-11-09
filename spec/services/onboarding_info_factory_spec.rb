# frozen_string_literal: true

require 'rails_helper'
require 'pie_for_providers_error' # TODO: add this to spec_helper.rb ?

# For the MVP, we can assume that any incoming data (e.g. json) is well formed: format is correct
#   and data is complete.
RSpec.describe OnboardingInfoFactory do
  let(:juan_ortiz_json) do
    { "first_name": 'Juan',
      "last_name": 'Oritz',
      "date_of_birth": '2015-04-14',
      "business_name": 'Happy Hearts Childcare',
      "business_zip_code": '60606',
      "business_county": 'Cook',
      "business_qris_rating": 'Gold',
      "case_number": '1234567',
      "full_days": '18',
      "part_days": '4',
      "effective_on": '2019-11-12',
      "expires_on": '2020-11-11',
      "co_pay": '10000',
      "co_pay_frequency": 'Monthly' }.to_json
  end
  # let(:juan_ortiz_json) { JSON.parse(juan_ortiz_json).to_h }

  let(:illinois) { build(:state, name: 'Illinois', abbr: 'IL') }
  let(:cook_county) { build(:county, name: 'Cook', state: illinois) }
  let(:cook_zip_06) { build(:zipcode, county: cook_county, code: '60606') }

  let(:happy_hearts_biz) { build(:business, name: 'Happy Hearts Childcare', zipcode: cook_zip_06) }
  let(:juan_approval) { build(:approval, case_number: '1234567', effective_on: Date.new(2019, 11, 12), expires_on: Date.new(2020, 11, 11)) }

  describe '.from_json' do
    it 'creates the business by the name and zip code if needed' do
      allow(described_class).to receive(:get_child_and_approvals)

      expect(described_class).to receive(:get_business)
      described_class.from_json(juan_ortiz_json)
    end

    it 'creates the Child and Approvals if needed' do
      allow(described_class).to receive(:get_business).and_return(happy_hearts_biz)

      expect(described_class).to receive(:get_child_and_approvals)
      described_class.from_json(juan_ortiz_json)
    end
  end

  describe '.get_business' do
    it 'looks up the zipcode' do
      allow(Business).to receive(:find_or_create_by!).and_return(happy_hearts_biz)

      expect(Zipcode).to receive(:find_by)
        .with({ code: '60606' })
        .and_return(cook_zip_06)
      described_class.get_business(juan_ortiz_json)
    end

    it 'raises an error if it cannot find the zipcode' do
      allow(Zipcode).to receive(:find_by).and_return(nil)

      expect(described_class).to receive(:raise_not_found_error).with(/Zipcode/).and_call_original
      expect { described_class.get_business(juan_ortiz_json) }.to raise_error(ItemNotFoundError)
    end

    context 'zipcode exists' do
      before(:each) do
        create(:admin)
        allow(Zipcode).to receive(:find_by).and_return(cook_zip_06)
      end

      context 'business does not exist' do
        it 'creates the business' do
          expect do
            new_biz = described_class.get_business(juan_ortiz_json)
            expect(new_biz.name).to eq 'Happy Hearts Childcare'
            expect(new_biz.zipcode.code).to eq '60606'
          end.to change { Business.count }.by(1)
        end

        it 'user is the first admin found' do
          new_biz = described_class.get_business(juan_ortiz_json)
          expect(new_biz.user.admin?).to be_truthy
        end
      end

      it 'returns the business' do
        allow(Business).to receive(:find_or_create_by!).and_return(happy_hearts_biz)
        expect(described_class.get_business(juan_ortiz_json)).to eq happy_hearts_biz
      end

      it 'raises error if it could not find or create the business' do
        allow(Business).to receive(:find_or_create_by!).and_return(nil)

        expect(described_class).to receive(:raise_not_found_error).with(/Business/).and_call_original
        expect { described_class.get_business(juan_ortiz_json) }.to raise_error(ItemNotFoundError)
      end
    end
  end

  describe '.get_child_and_approvals' do
    it 'creates the full name from the first and last name' do
      kid = double(Child)
      allow(kid).to receive(:approvals).and_return([])
      allow(Child).to receive(:create!).and_return(kid)
      allow(described_class).to receive(:get_approval)
      allow(ChildApprovalFactory).to receive(:new)

      expect(Child).to receive(:find_by).with(hash_including(full_name: 'Juan Oritz'))
                                        .and_return(nil)
      described_class.get_child_and_approvals(juan_ortiz_json, 'some biz would be here')
    end

    context 'child already exists with full name, birthdate, for the business' do
      it 'skips the row' do
        kid = double(Child)
        allow(kid).to receive(:approvals).and_return([])
        allow(Child).to receive(:find_by).and_return(kid)
        allow(described_class).to receive(:get_approval)

        expect(Child).not_to receive(:create!)
        described_class.get_child_and_approvals(juan_ortiz_json, 'some business')
      end
    end

    context 'child does not exist with full name, birthdate, for the business' do
      it 'creates the child with that name & birthdate, for the business' do
        allow(described_class).to receive(:get_approval).and_return(juan_approval)
        allow(Child).to receive(:find_by).and_return(nil)

        biz = build(:business)
        kid = double(Child)
        allow(kid).to receive(:approvals).and_return([])
        allow(described_class).to receive(:get_approval)
        allow(ChildApprovalFactory).to receive(:new)

        expect(Child).to receive(:create!).with(hash_including(full_name: 'Juan Oritz',
                                                               date_of_birth: Date.new(2015, 4, 14),
                                                               business: biz))
                                          .and_return(kid)
        described_class.get_child_and_approvals(juan_ortiz_json, biz)
      end

      it 'gets the Approval and associates it with the child' do
        allow(Child).to receive(:find_by).and_return(nil)
        biz = build(:business)
        kid = double(Child)
        allow(Child).to receive(:create!).and_return(kid)
        allow(kid).to receive(:approvals).and_return([juan_approval])
        allow(ChildApprovalFactory).to receive(:new)

        expect(described_class).to receive(:get_approval).with(juan_ortiz_json)
                                                         .and_return(juan_approval)
        described_class.get_child_and_approvals(juan_ortiz_json, biz)
      end
    end

    it 'calls ChildApprovalFactory to create the ChildApproval for the child and approval created for it' do
      allow(Child).to receive(:find_by).and_return(nil)
      biz = build(:business)
      kid = double(Child)
      allow(kid).to receive(:approvals).and_return([build(:approval)])
      allow(Child).to receive(:create!).and_return(kid)

      allow(described_class).to receive(:get_approval).and_return(juan_approval)

      expect(ChildApprovalFactory).to receive(:new).with(kid, kid.approvals.first)
      described_class.get_child_and_approvals(juan_ortiz_json, biz)
    end
  end

  describe '.get_approval' do
    it 'raises error if approval with the case number does not exist' do
      allow(Approval).to receive(:find_by).and_return(nil)
      expect { described_class.get_approval(juan_ortiz_json) }.to raise_error(ItemNotFoundError)
    end

    it 'returns the approval with the given case number' do
      juan_approval.save
      expect { described_class.get_approval(juan_ortiz_json) }.not_to(change { Approval.count })
      expect(described_class.get_approval(juan_ortiz_json).id).to eq(juan_approval.id)
    end
  end

  describe '.raise_not_found_error' do
    it 'raises the ItemNotFoundError and prepends the message with the given string' do
      expect { described_class.raise_not_found_error('more info') }.to raise_error(ItemNotFoundError, /more info/)
    end
  end
end
