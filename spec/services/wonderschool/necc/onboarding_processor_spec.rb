# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe OnboardingProcessor do
      let!(:onboarding_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_onboarding_data.csv') }
      let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_onboarding_data_invalid_format.csv') }
      let!(:valid_string) do
        <<~CSV
          Full Name,Client ID,Provider Name,Date of birth (required),Enrolled in School (Kindergarten or later),Case number,Authorized full day units,Authorized hourly units,Effective on,Expires on,Special Needs Rate?,Special Needs Daily Rate,Special Needs Hourly Rate,Provider Email,Business Zip Code,Business County,Business License,Business QRIS rating,Accredited,Approval #1 - Family Fee,Approval #1 - Begin Date,Approval #1 - End Date,Approval #1 - Allocated Family Fee,Approval #2 - Family Fee,Approval #2 - Begin Date,Approval #2 - End Date,Approval #2 - Allocated Family Fee,Approval #3 - Family Fee,Approval #3 - Begin Date,Approval #3 - End Date,Approval #3 - Allocated Family Fee,Approval #4 - Family Fee,Approval #4 - Begin Date,Approval #4 - End Date,Approval #4 - Allocated Family Fee,Approval #5 - Family Fee,Approval #5 - Begin Date,Approval #5 - End Date,Approval #5 - Allocated Family Fee
          Thomas Eddleman,14047907,Rebecca's Childcare,2010-09-01,No,14635435,276,"1,656",2020-09-01,2021-08-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,0.00,2020-09-01,2021-08-31,0.00,,,,,,,,,,,,,,,,
          Jacob Ford,31610139,Rebecca's Childcare,2017-09-01,No,14635435,276,"1,656",2020-09-01,2021-08-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,0.00,2020-09-01,2021-08-31,0.00,,,,,,,,,,,,,,,,
          Linda Rogers,15228275,Rebecca's Childcare,2019-02-21,No,14635435,276,"1,656",2020-09-01,2021-08-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,0.00,2020-09-01,2021-08-31,0.00,,,,,,,,,,,,,,,,
          Paz Korman,81185504,Rebecca's Childcare,2017-05-17,No,12312445,138,828,2021-01-29,2021-07-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,108.00,2021-01-29,2021-07-31,108.00,,,,,,,,,,,,,,,,
          Becky Falzone,69370816,Kate's Kids,2013-12-26,No,56582912,330,"1,760",2020-11-24,2021-11-23,Yes,90.77,9.43,kate@kate.com,68845,Corke,Family Child Care Home I,Step 5,No,60.00,2020-11-24,2021-05-23,60.00,85.00,2021-05-24,2021-11-23,85.00,,,,,,,,,,,,
        CSV
      end
      let(:invalid_string) do
        <<~CSV
          wrong_headers,icon,face
          nope,yep,maybe
        CSV
      end
      let!(:first_user) { create(:user, email: 'rebecca@rebecca.com') }
      let!(:second_user) { create(:user, email: 'kate@kate.com') }

      RSpec.shared_examples 'creates thomas' do
        it "sets Thomas' attributes correctly", use_truncation: true do
          described_class.new(source_data).call
          thomas = Child.find_by(full_name: 'Thomas Eddleman')
          expect(thomas).to have_attributes(
            {
              dhs_id: '14047907',
              date_of_birth: Date.parse('2010-09-01'),
              enrolled_in_school: false
            }
          )
          expect(thomas.business).to have_attributes(
            {
              name: "Rebecca's Childcare",
              zipcode: '68845',
              county: 'Corke',
              qris_rating: 'Step 4',
              accredited: true
            }
          )
          expect(thomas.user).to eq(first_user)
          expect(thomas.approvals.first).to have_attributes(
            {
              case_number: '14635435',
              effective_on: Date.parse('2020-09-01'),
              expires_on: Date.parse('2021-08-31')
            }
          )
          expect(thomas.child_approvals.first).to have_attributes(
            {
              full_days: 276,
              hours: 1656,
              special_needs_rate: false,
              special_needs_daily_rate: nil,
              special_needs_hourly_rate: nil
            }
          )
          expect(thomas.child_approvals.first.nebraska_approval_amounts.count).to eq(1)
          expect(thomas.child_approvals.first.nebraska_approval_amounts.first).to have_attributes(
            {
              effective_on: Date.parse('2020-09-01'),
              expires_on: Date.parse('2021-08-31'),
              family_fee: 0,
              allocated_family_fee: 0
            }
          )
        end
      end

      RSpec.shared_examples 'creates becky' do
        it "sets Becky's attributes correctly", use_truncation: true do
          described_class.new(source_data).call
          becky = Child.find_by(full_name: 'Becky Falzone')
          expect(becky).to have_attributes(
            {
              dhs_id: '69370816',
              date_of_birth: Date.parse('2013-12-26'),
              enrolled_in_school: false
            }
          )
          expect(becky.business).to have_attributes(
            {
              name: "Kate's Kids",
              zipcode: '68845',
              county: 'Corke',
              qris_rating: 'Step 5',
              accredited: false
            }
          )
          expect(becky.user).to eq(second_user)
          expect(becky.approvals.first).to have_attributes(
            {
              case_number: '56582912',
              effective_on: Date.parse('2020-11-24'),
              expires_on: Date.parse('2021-11-23')
            }
          )
          expect(becky.child_approvals.first).to have_attributes(
            {
              full_days: 330,
              hours: 1760,
              special_needs_rate: true,
              special_needs_daily_rate: 90.77,
              special_needs_hourly_rate: 9.43
            }
          )
          expect(becky.child_approvals.first.nebraska_approval_amounts.count).to eq(2)
          expect(becky.child_approvals.first.nebraska_approval_amounts.find_by(
                   effective_on: Date.parse('2020-11-24')
                 )).to have_attributes(
                   {
                     effective_on: Date.parse('2020-11-24'),
                     expires_on: Date.parse('2021-05-23'),
                     family_fee: 60.00,
                     allocated_family_fee: 60.00
                   }
                 )
          expect(becky.child_approvals.first.nebraska_approval_amounts.find_by(
                   effective_on: Date.parse('2021-05-24')
                 )).to have_attributes(
                   {
                     effective_on: Date.parse('2021-05-24'),
                     expires_on: Date.parse('2021-11-23'),
                     family_fee: 85.00,
                     allocated_family_fee: 85.00
                   }
                 )
        end
      end

      RSpec.shared_examples 'adds model record count' do
        it 'creates Child records for every row in the file, idempotently', use_truncation: true do
          expect { described_class.new(source_data).call }
            .to change { Child.count }
            .from(0).to(5)
            .and change { Business.count }
            .from(0).to(2)
            .and change { ChildApproval.count }
            .from(0).to(5)
            .and change { Approval.count }
            .from(0).to(3)
            .and change { NebraskaApprovalAmount.count }
            .from(0).to(6)
          expect { described_class.new(source_data).call }
            .to not_change(Child, :count)
            .and not_change(Business, :count)
            .and not_change(ChildApproval, :count)
            .and not_change(Approval, :count)
            .and not_change(NebraskaApprovalAmount, :count)
        end
      end

      RSpec.shared_examples 'logs failed records' do
        let(:failed_subsidy_case) do
          [
            [
              ['Full Name', 'Becky Falzone'],
              ['Client ID', '69370816'],
              ['Provider Name', "Kate's Kids"],
              ['Date of birth (required)', Date.parse('2013-12-26')],
              ['Enrolled in School (Kindergarten or later)', 'No'],
              ['Case number', '56582912'],
              ['Authorized full day units', '330'],
              ['Authorized hourly units', '1,760'],
              ['Effective on', Date.parse('2020-11-24')],
              ['Expires on', Date.parse('2021-11-23')],
              ['Special Needs Rate?', 'Yes'],
              ['Special Needs Daily Rate', '90.77'],
              ['Special Needs Hourly Rate', '9.43'],
              ['Provider Email', 'kate@kate.com'],
              ['Business Zip Code', '68845'],
              ['Business County', 'Corke'],
              ['Business License', 'Family Child Care Home I'],
              ['Business QRIS rating', 'Step 5'],
              %w[Accredited No],
              ['Approval #1 - Family Fee', '60.00'],
              ['Approval #1 - Begin Date', Date.parse('2020-11-24')],
              ['Approval #1 - End Date', Date.parse('2021-05-23')],
              ['Approval #1 - Allocated Family Fee', '60.00'],
              ['Approval #2 - Family Fee', '85.00'],
              ['Approval #2 - Begin Date', Date.parse('2021-05-24')],
              ['Approval #2 - End Date', Date.parse('2021-11-23')],
              ['Approval #2 - Allocated Family Fee', '85.00'],
              ['Approval #3 - Family Fee', nil],
              ['Approval #3 - Begin Date', nil],
              ['Approval #3 - End Date', nil],
              ['Approval #3 - Allocated Family Fee', nil],
              ['Approval #4 - Family Fee', nil],
              ['Approval #4 - Begin Date', nil],
              ['Approval #4 - End Date', nil],
              ['Approval #4 - Allocated Family Fee', nil],
              ['Approval #5 - Family Fee', nil],
              ['Approval #5 - Begin Date', nil],
              ['Approval #5 - End Date', nil],
              ['Approval #5 - Allocated Family Fee', nil]
            ]
          ].flatten.to_s
        end
        it "does not stop the job if the user doesn't exist, and logs the failed case", use_truncation: true do
          second_user.destroy!
          expect(stubbed_client).to receive(:put_object).with(
            {
              bucket: archive_bucket,
              body: failed_subsidy_case, key: file_name
            }
          )
          # TODO: this gets called 13 times for some reason?
          # expect(Rails.logger).to receive(:tagged).and_yield
          # expect(Rails.logger).to receive(:error).with(failed_subsidy_case)
          described_class.new(source_data).call
        end
      end

      describe '.call' do
        let!(:file_name) { 'failed_subsidy_cases' }
        let!(:archive_bucket) { 'archive_bucket' }
        let!(:stubbed_client) { double('AWS Client') }
        let!(:stubbed_processor) { double('Wonderschool Necc Onboarding Processor') }
        let!(:stubbed_object) { double('S3 Object') }
        before do
          allow(ENV).to receive(:fetch).with('AWS_NECC_ONBOARDING_ARCHIVE_BUCKET', '').and_return(archive_bucket)
          allow(ENV).to receive(:fetch).with('AWS_ACCESS_KEY_ID', '').and_return('fake_key')
          allow(ENV).to receive(:fetch).with('AWS_SECRET_ACCESS_KEY', '').and_return('fake_secret')
          allow(ENV).to receive(:fetch).with('AWS_REGION', '').and_return('fake_region')
          allow(Aws::S3::Client).to receive(:new) { stubbed_client }
        end
        context "when a file name passed in doesn't exist" do
          it 'returns false' do
            expect(described_class.new(Rails.root.join('fake.csv')).call).to eq(false)
          end
        end

        context 'with a valid string' do
          let(:source_data) { valid_string }
          include_examples 'creates thomas'
          include_examples 'creates becky'
          include_examples 'adds model record count'
          include_examples 'logs failed records'
        end

        context 'with a valid stream' do
          let(:source_data) { StringIO.new(valid_string) }
          include_examples 'creates thomas'
          include_examples 'creates becky'
          include_examples 'adds model record count'
          include_examples 'logs failed records'
        end

        context 'with a valid file' do
          let(:source_data) { onboarding_csv }
          include_examples 'creates thomas'
          include_examples 'creates becky'
          include_examples 'adds model record count'
          include_examples 'logs failed records'
        end

        context 'when the csv data is the wrong format from a file' do
          let(:source_data) { invalid_csv }
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }
          it 'returns false' do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            expect(described_class.new(invalid_csv).call).to eq(false)
          end
        end

        context 'when the csv data is the wrong format from a string' do
          let(:source_data) { invalid_string }
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }
          it 'returns false' do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            expect(described_class.new("wrong_headers,icon,face\nnope,yep,maybe").call).to eq(false)
          end
        end

        context 'when the csv data is the wrong format from a stream' do
          let(:source_data) { StringIO.new(invalid_string) }
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }
          it 'returns false' do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            expect(described_class.new(StringIO.new("wrong_headers,icon,face\nnope,yep,maybe")).call).to eq(false)
          end
        end
      end
    end
  end
end
