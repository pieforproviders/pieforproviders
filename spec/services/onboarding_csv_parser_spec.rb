# frozen_string_literal: true

require 'rails_helper'

# For the MVP, we can assume that the CSV file is well formed: format is correct
#   and data is complete.
RSpec.describe OnboardingCsvParser do
  let(:headers) do
    %w[first_name
       last_name
       date_of_birth
       business_name
       business_zip_code
       business_county
       business_qris_rating
       case_number full_days
       part_days
       effective_on
       expires_on
       co_pay
       co_pay_frequency]
  end
  let(:header_row) { "#{headers.join(',')}\n" }

  let(:juan_ortiz_row) { 'Juan, Oritz,2015-04-14, Happy Hearts Childcare,60606 , Cook,Gold, 1234567, 18,4,2019-11-12,2020-11-12,10000,Monthly' }
  let(:julia_ortiz_row) { 'Julia, Oritz,2017-12-01, Happy Hearts Childcare,60606-3566, Cook,Gold, 1234567,22,5,2019-11-12,2020-11-12,10000,Monthly' }

  let(:valid_1_row_csv) { header_row + juan_ortiz_row }

  let(:csv_row_juan_ortiz) do
    CSV::Row.new(headers,
                 ['Juan',
                  'Oritz',
                  Date.new(2015, 4, 14),
                  'Happy Hearts Childcare',
                  '60606',
                  'Cook',
                  'Gold',
                  '1234567',
                  18,
                  4,
                  Date.new(2019, 11, 12),
                  Date.new(2020, 11, 12),
                  10_000,
                  'Monthly'])
  end

  let(:illinois) { build(:state, name: 'Illinois', abbr: 'IL') }
  let(:cook_county) { build(:county, name: 'Cook', state: illinois) }
  let(:cook_zip_06) { build(:zipcode, county: cook_county, code: '60606') }

  let(:happy_hearts_biz) { create(:business, name: 'Happy Hearts Childcare', zipcode: cook_zip_06) }

  describe '.parse' do
    it 'gets the business by the name and zip code' do
      allow(described_class).to receive(:import_child_and_related)

      expect(described_class).to receive(:get_business)
      described_class.parse(valid_1_row_csv)
    end

    it 'imports the child on the row with the business imported' do
      allow(described_class).to receive(:get_business)

      expect(described_class).to receive(:import_child_and_related)
      described_class.parse(valid_1_row_csv)
    end
  end

  describe '.import_child_and_related' do
    it 'creates the full name from the first and last name' do
      kid = double(Child)
      allow(kid).to receive(:approvals).and_return([])
      allow(Child).to receive(:create!).and_return(kid)
      allow(described_class).to receive(:get_approval)
      allow(described_class).to receive(:create_child_approval)

      expect(Child).to receive(:find_by).with(hash_including(full_name: 'Juan Oritz'))
                                        .and_return(nil)
      described_class.import_child_and_related(csv_row_juan_ortiz, 'some biz would be here')
    end

    context 'child already exists with full name, birthdate, for the business' do
      it 'skips the row' do
        kid = double(Child)
        allow(kid).to receive(:approvals).and_return([])
        allow(Child).to receive(:find_by).and_return(kid)
        allow(described_class).to receive(:get_approval)
        allow(described_class).to receive(:create_child_approval)

        expect(Child).not_to receive(:create!)
        described_class.import_child_and_related(csv_row_juan_ortiz, 'some business')
      end
    end

    context 'child does not exist with full name, birthdate, for the business' do
      it 'creates the child with that name & birthdate, for the business' do
        allow(described_class).to receive(:get_approval).and_return(build(:approval))
        allow(described_class).to receive(:create_child_approval)
        allow(Child).to receive(:find_by).and_return(nil)

        biz = build(:business)
        kid = double(Child)
        allow(kid).to receive(:approvals).and_return([])

        expect(Child).to receive(:create!).with(hash_including(full_name: 'Juan Oritz',
                                                               date_of_birth: Date.new(2015, 4, 14),
                                                               business: biz))
                                          .and_return(kid)
        described_class.import_child_and_related(csv_row_juan_ortiz, biz)
      end

      it 'gets the Approval and associates it with the child' do
        allow(described_class).to receive(:create_child_approval)
        allow(Child).to receive(:find_by).and_return(nil)

        biz = build(:business)
        kid = double(Child)
        allow(kid).to receive(:approvals).and_return([])
        allow(Child).to receive(:create!).and_return(kid)

        expect(described_class).to receive(:get_approval).with(csv_row_juan_ortiz)
        described_class.import_child_and_related(csv_row_juan_ortiz, biz)
      end
    end
  end

  describe '.create_child_approval' do
    let(:biz) { create(:business, county: cook_county, zipcode: cook_zip_06) }
    let(:kid) { create(:child, date_of_birth: Date.current - 6.years + 20.days, business: biz) }

    it 'gets the subsidy rule' do
      allow(ChildApproval).to receive(:find_or_create_by!).and_return(build(:child_approval,
                                                                            child: kid))
      expect(described_class).to receive(:get_subsidy_rule)
        .with(6.9454, cook_county, illinois, { effective_on: Date.current })
      described_class.create_child_approval(kid, kid.approvals.first)
    end

    it 'adds the child_approval to the child' do
      described_class.create_child_approval(kid, kid.approvals.first)
      expect(kid.child_approvals.size).to eq 1
    end
  end

  describe '.get_approval' do
    let(:juan_ortiz_row_approval) { CSV::Row.new(headers, juan_ortiz_row.split(',')) }

    it 'raises error if approval  with the case number does not exist' do
      allow(Approval).to receive(:find_by).and_return(nil)
      expect { described_class.get_approval(juan_ortiz_row_approval) }.to raise_error(ItemNotFoundError)
    end

    it 'returns the approval with the given case number' do
      juans_approval = Approval.create!(case_number: juan_ortiz_row_approval['case_number'].strip,
                                        effective_on: Date.parse(juan_ortiz_row_approval['effective_on']),
                                        expires_on: Date.parse(juan_ortiz_row_approval['expires_on']))

      expect { described_class.get_approval(juan_ortiz_row_approval) }.not_to(change { Approval.count })
      expect(described_class.get_approval(juan_ortiz_row_approval).id).to eq(juans_approval.id)
    end
  end

  describe '.get_subsidy_rule' do
    it 'calls SubsidyRule to get the rule based on child age, business state & county and effective_on date' do
      given_date = Date.current - 2.days
      expect(SubsidyRule).to receive(:age_county_state).with(5, cook_county, illinois, { effective_on: given_date })
      described_class.get_subsidy_rule(5, cook_county, illinois,
                                       effective_on: given_date)
    end

    it 'default effective_on is Date.current' do
      expect(SubsidyRule).to receive(:age_county_state).with(5, cook_county, illinois, { effective_on: Date.current })
      described_class.get_subsidy_rule(5, cook_county, illinois)
    end
  end

  describe '.raise_not_found_error' do
    it 'raises the ItemNotFoundError and prepends the message with the given string' do
      expect { described_class.raise_not_found_error('more info') }.to raise_error(ItemNotFoundError, /more info/)
    end
  end
end
