# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe DashboardProcessor do
      let!(:dashboard_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data.csv') }
      let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data_invalid_format.csv') }
      let!(:missing_field_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data_missing_field.csv') }
      let!(:valid_string) do
        <<~CSV
          As of Date,Child Name,Case Number,Business,Full Days,Hourly,Absences,Hours Attended,Status,Earned revenue,Estimated Revenue,Approved (Scheduled) revenue,Family Fee
          2021-02-21,Sarah Brighton,23434235,Test Day Care,0 of 20,0 of 0,1 of 3,4 of 6,at_risk,0,90.77,1815.40,120.00
          2021-02-25,Charles Williamson,23434235,Test Day Care,1 of 15,1 of 18,3 of 4,1 of 2,on_track,98.21,1234.56,1815.40,25.00
          2021-02-24,Marcus Wright,23434235,Test Day Care,3 of 15,4 of 18,0 of 1,12 of 14,exceeded_limit,330.00,330.00,1815.40,105.75
        CSV
      end
      let!(:missing_field_string) do
        <<~CSV
          As of Date,Child Name,Case Number,Business,Full Days,Hourly,Hours Attended,Status,Earned revenue,Estimated Revenue,Approved (Scheduled) revenue,Family Fee
          2021-02-21,Sarah Brighton,23434235,Test Day Care,0 of 20,0 of 0,4 of 6,at_risk,0,90.77,1815.40,120.00
          2021-02-25,Charles Williamson,23434235,Test Day Care,1 of 15,1 of 18,1 of 2,on_track,98.21,1234.56,1815.40,25.00
          2021-02-24,Marcus Wright,23434235,Test Day Care,3 of 15,4 of 18,12 of 14,exceeded_limit,330.00,330.00,1815.40,105.75
        CSV
      end
      let!(:business) { create(:business, name: 'Test Day Care') }
      let!(:first_child) { create(:necc_child, full_name: 'Sarah Brighton', business: business) }
      let!(:second_child) { create(:necc_child, full_name: 'Charles Williamson', business: business) }
      let!(:third_child) { create(:necc_child, full_name: 'Marcus Wright', business: business) }

      let!(:file_name) { 'failed_dashboard_cases' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:stubbed_client) { double('AWS Client') }

      let(:error_log) do
        [
          [
            ['As of Date', Date.parse('2021-02-21')],
            ['Child Name', 'Sarah Brighton'],
            ['Case Number', '23434235'],
            ['Business', 'Test Day Care'],
            ['Full Days', '0 of 20'],
            ['Hourly', '0 of 0'],
            ['Absences', '1 of 3'],
            ['Hours Attended', '4 of 6'],
            %w[Status at_risk],
            ['Earned revenue', '0'],
            ['Estimated Revenue', '90.77'],
            ['Approved (Scheduled) revenue', '1815.40'],
            ['Family Fee', '120.00']
          ]
        ].flatten.to_s
      end

      let(:missing_field_error_log) do
        [
          [
            ['As of Date', Date.parse('2021-02-21')],
            ['Child Name', 'Sarah Brighton'],
            ['Case Number', '23434235'],
            ['Business', 'Test Day Care'],
            ['Full Days', '0 of 20'],
            ['Hourly', '0 of 0'],
            ['Hours Attended', '4 of 6'],
            %w[Status at_risk],
            ['Earned revenue', '0'],
            ['Estimated Revenue', '90.77'],
            ['Approved (Scheduled) revenue', '1815.40'],
            ['Family Fee', '120.00']
          ],
          [
            ['As of Date', Date.parse('2021-02-25')],
            ['Child Name', 'Charles Williamson'],
            ['Case Number', '23434235'],
            ['Business', 'Test Day Care'],
            ['Full Days', '1 of 15'],
            ['Hourly', '1 of 18'],
            ['Hours Attended', '1 of 2'],
            %w[Status on_track],
            ['Earned revenue', '98.21'],
            ['Estimated Revenue', '1234.56'],
            ['Approved (Scheduled) revenue', '1815.40'],
            ['Family Fee', '25.00']
          ],
          [
            ['As of Date', Date.parse('2021-02-24')],
            ['Child Name', 'Marcus Wright'],
            ['Case Number', '23434235'],
            ['Business', 'Test Day Care'],
            ['Full Days', '3 of 15'],
            ['Hourly', '4 of 18'],
            ['Hours Attended', '12 of 14'],
            %w[Status exceeded_limit],
            ['Earned revenue', '330.00'],
            ['Estimated Revenue', '330.00'],
            ['Approved (Scheduled) revenue', '1815.40'],
            ['Family Fee', '105.75']
          ]
        ].flatten.to_s
      end

      RSpec.shared_examples 'updates sarah' do
        it "sets sarah's attributes correctly" do
          described_class.new(input).call
          expect(first_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-21')
          expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('1 of 3')
          expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
          expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('0')
          expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('90.77')
          expect(first_child.temporary_nebraska_dashboard_case.family_fee).to eq(120.00)
          expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('0 of 20')
          expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('0 of 0')
          expect(first_child.temporary_nebraska_dashboard_case.hours_attended).to eq('4 of 6')
        end
      end
      RSpec.shared_examples 'updates charles' do
        it "sets charles' attributes correctly" do
          described_class.new(input).call
          expect(second_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-25')
          expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('3 of 4')
          expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
          expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
          expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
          expect(second_child.temporary_nebraska_dashboard_case.family_fee).to eq(25.00)
          expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
          expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
          expect(second_child.temporary_nebraska_dashboard_case.hours_attended).to eq('1 of 2')
        end
      end
      RSpec.shared_examples 'updates marcus' do
        it "sets marcus' attributes correctly" do
          described_class.new(input).call
          expect(third_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-24')
          expect(third_child.temporary_nebraska_dashboard_case.absences).to eq('0 of 1')
          expect(third_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('exceeded_limit')
          expect(third_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('330.00')
          expect(third_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('330.00')
          expect(third_child.temporary_nebraska_dashboard_case.family_fee).to eq(105.75)
          expect(third_child.temporary_nebraska_dashboard_case.full_days).to eq('3 of 15')
          expect(third_child.temporary_nebraska_dashboard_case.hours).to eq('4 of 18')
          expect(third_child.temporary_nebraska_dashboard_case.hours_attended).to eq('12 of 14')
        end
      end

      RSpec.shared_examples 'creates records, attributes, does not stop job on failure to find child' do
        it 'creates dashboard records for every row in the file, idempotently' do
          expect { described_class.new(input).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
          expect { described_class.new(input).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
        end

        include_examples 'updates sarah'
        include_examples 'updates charles'
        include_examples 'updates marcus'

        it "does not stop the job if the child doesn't exist, and logs the failed child" do
          first_child.destroy!
          expect(stubbed_client).to receive(:put_object).with(
            {
              bucket: archive_bucket,
              body: error_log, key: file_name
            }
          )
          allow(Rails.logger).to receive(:tagged).and_yield
          expect(Rails.logger).to receive(:error).with(error_log)
          described_class.new(input).call
        end
      end

      RSpec.shared_examples 'invalid dashboard input returns false' do
        it 'returns false' do
          expect(stubbed_client).to receive(:put_object).with(
            {
              bucket: archive_bucket,
              body: error_log, key: file_name
            }
          )
          allow(Rails.logger).to receive(:tagged).and_yield
          expect(Rails.logger).to receive(:error).with(error_log)
          expect(described_class.new(invalid_input).call).to eq(false)
        end
      end

      RSpec.shared_examples 'failure to update dashboard case returns false' do
        it 'returns false' do
          expect(stubbed_client).to receive(:put_object).with(
            {
              bucket: archive_bucket,
              body: missing_field_error_log, key: file_name
            }
          )
          allow(Rails.logger).to receive(:tagged).and_yield
          expect(Rails.logger).to receive(:error).with(missing_field_error_log)
          expect(described_class.new(invalid_input).call).to eq(false)
        end
      end

      describe '.call' do
        before do
          allow(Rails.application.config).to receive(:aws_necc_dashboard_archive_bucket).and_return(archive_bucket)
          allow(Aws::S3::Client).to receive(:new) { stubbed_client }
        end

        context "when a file name passed in doesn't exist" do
          it 'returns false' do
            expect(described_class.new(Rails.root.join('fake.csv')).call).to eq(false)
          end
        end

        context 'with a valid string' do
          let(:input) { valid_string }
          include_examples 'creates records, attributes, does not stop job on failure to find child'
        end

        context 'with a valid file' do
          let(:input) { dashboard_csv }
          include_examples 'creates records, attributes, does not stop job on failure to find child'
        end

        context 'when the csv data is the wrong format' do
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }

          context 'from a string' do
            let(:invalid_input) { "wrong_headers,icon,face\nnope,yep,maybe" }
            include_examples 'invalid dashboard input returns false'
          end

          context 'from a file' do
            let(:invalid_input) { invalid_csv }
            include_examples 'invalid dashboard input returns false'
          end
        end

        context 'when the csv data is missing a field' do
          context 'from a string' do
            let(:invalid_input) { missing_field_string }
            include_examples 'failure to update dashboard case returns false'
          end

          context 'from a file' do
            let(:invalid_input) { missing_field_csv }
            include_examples 'failure to update dashboard case returns false'
          end
        end
      end
    end
  end
end
