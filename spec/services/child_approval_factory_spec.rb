# frozen_string_literal: true

require 'rails_helper'
require 'pie_for_providers_error' # TODO: add this to spec_helper.rb ?

# specifications and tests for ChildApprovalFactory
RSpec.describe ChildApprovalFactory do
  let(:illinois) { build(:state, name: 'Illinois', abbr: 'IL') }
  let(:cook_county) { build(:county, name: 'Cook', state: illinois) }
  let(:cook_zip_06) { build(:zipcode, county: cook_county, code: '60606') }

  let(:happy_hearts_biz) { create(:business, name: 'Happy Hearts Childcare', zipcode: cook_zip_06) }

  let(:biz) { create(:business, county: cook_county, zipcode: cook_zip_06) }
  let(:kid) { create(:child, date_of_birth: Date.current - 6.years + 20.days, business: biz) }

  describe 'initialize' do
    it 'child cannot be nil' do
      expect { described_class.new(nil, create(:approval)) }.to raise_error(ArgumentError, /child cannot be nil/)
    end

    it 'approval cannot be nil' do
      expect { described_class.new(create(:child), nil) }.to raise_error(ArgumentError, /approval cannot be nil/)
    end

    it 'gets the subsidy rule' do
      allow(ChildApproval).to receive(:find_or_create_by!).and_return(build(:child_approval,
                                                                            child: kid))
      expect(SubsidyRuleFinder).to receive(:for).with(kid, Date.current).and_return(build(:subsidy_rule))

      described_class.new(kid, kid.approvals.first)
    end

    it 'raises error if could not find or create a ChildApproval' do
      allow(SubsidyRuleFinder).to receive(:for).with(kid, Date.current).and_return(build(:subsidy_rule))
      allow(ChildApproval).to receive(:find_or_create_by!).and_return(nil)

      expect { described_class.new(kid, kid.approvals.first) }.to raise_error(/Could not find_or_create_by! a ChildApproval/)
    end

    it 'adds the child_approval to the child' do
      allow(SubsidyRuleFinder).to receive(:for).with(kid, Date.current).and_return(build(:subsidy_rule))

      described_class.new(kid, kid.approvals.first)
      expect(kid.child_approvals.size).to eq 1
    end
  end
end
