# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe DashboardProcessor do
      let!(:dashboard_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data.csv') }
      let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data_invalid_format.csv') }
      let!(:valid_string) do
        <<~CSV
          As of Date,Child Name,Case Number,Business,Full Days,Hourly,Absences,Status,Earned revenue,Estimated Revenue,Approved (Scheduled) revenue,Transportation revenue
          2021-02-21,Sarah Brighton,23434235,Test Day Care,0 of 20,0 of 0,"0 days, 0 hours",at_risk,0,90.77,"1,815.40",n/a
          2021-02-25,Charles Williamson,23434235,Test Day Care,1 of 15,1 of 18,"1 day, 0 hours",on_track,98.21,1234.56,"1,815.40",2 trips - $22.00
          2021-02-24,Marcus Wright,23434235,Test Day Care,3 of 15,4 of 18,"0 days, 4 hours",exceeded_limit,330.00,330.00,"1,815.40",n/a
        CSV
      end
      let!(:first_child) { create(:necc_child, full_name: 'Sarah Brighton') }
      let!(:second_child) { create(:necc_child, full_name: 'Charles Williamson') }
      let!(:third_child) { create(:necc_child, full_name: 'Marcus Wright') }

      let(:error_log) do
        [
          [
            ['As of Date', Date.parse('2021-02-21')],
            ['Child Name', 'Sarah Brighton'],
            ['Case Number', '23434235'],
            ['Business', 'Test Day Care'],
            ['Full Days', '0 of 20'],
            ['Hourly', '0 of 0'],
            ['Absences', '0 days, 0 hours'],
            %w[Status at_risk],
            ['Earned revenue', '0'],
            ['Estimated Revenue', '90.77'],
            ['Approved (Scheduled) revenue', '1,815.40'],
            ['Transportation revenue', 'n/a']
          ]
        ].flatten.to_s
      end

      describe '.call' do
        let!(:file_name) { 'failed_dashboard_cases' }
        let!(:archive_bucket) { 'archive_bucket' }
        let!(:stubbed_client) { double('AWS Client') }
        let!(:stubbed_processor) { double('Wonderschool Necc Dashboard Processor') }
        let!(:stubbed_object) { double('S3 Object') }
        before do
          allow(ENV).to receive(:fetch).with('AWS_NECC_DASHBOARD_ARCHIVE_BUCKET', '').and_return(archive_bucket)
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
          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new(valid_string).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
            expect { described_class.new(valid_string).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            described_class.new(valid_string).call
            expect(first_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-21')
            expect(second_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-25')
            expect(third_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-24')
            expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('0 days, 0 hours')
            expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('1 day, 0 hours')
            expect(third_child.temporary_nebraska_dashboard_case.absences).to eq('0 days, 4 hours')
            expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
            expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
            expect(third_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('exceeded_limit')
            expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('0')
            expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
            expect(third_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('90.77')
            expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
            expect(third_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('0 of 20')
            expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
            expect(third_child.temporary_nebraska_dashboard_case.full_days).to eq('3 of 15')
            expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('0 of 0')
            expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
            expect(third_child.temporary_nebraska_dashboard_case.hours).to eq('4 of 18')
            expect(first_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('n/a')
            expect(second_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('2 trips - $22.00')
            expect(third_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('n/a')
          end

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
            described_class.new(valid_string).call
          end
        end

        context 'with a valid stream' do
          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new(StringIO.new(valid_string)).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
            expect { described_class.new(StringIO.new(valid_string)).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            described_class.new(StringIO.new(valid_string)).call
            expect(first_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-21')
            expect(second_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-25')
            expect(third_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-24')
            expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('0 days, 0 hours')
            expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('1 day, 0 hours')
            expect(third_child.temporary_nebraska_dashboard_case.absences).to eq('0 days, 4 hours')
            expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
            expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
            expect(third_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('exceeded_limit')
            expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('0')
            expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
            expect(third_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('90.77')
            expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
            expect(third_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('0 of 20')
            expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
            expect(third_child.temporary_nebraska_dashboard_case.full_days).to eq('3 of 15')
            expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('0 of 0')
            expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
            expect(third_child.temporary_nebraska_dashboard_case.hours).to eq('4 of 18')
            expect(first_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('n/a')
            expect(second_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('2 trips - $22.00')
            expect(third_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('n/a')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            first_child.destroy!
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            described_class.new(StringIO.new(valid_string)).call
          end
        end

        context 'with a valid file' do
          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new(dashboard_csv).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
            expect { described_class.new(dashboard_csv).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            described_class.new(dashboard_csv).call
            expect(first_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-21')
            expect(second_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-25')
            expect(third_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-24')
            expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('0 days, 0 hours')
            expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('1 day, 0 hours')
            expect(third_child.temporary_nebraska_dashboard_case.absences).to eq('0 days, 4 hours')
            expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
            expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
            expect(third_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('exceeded_limit')
            expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('0')
            expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
            expect(third_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('90.77')
            expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
            expect(third_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('0 of 20')
            expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
            expect(third_child.temporary_nebraska_dashboard_case.full_days).to eq('3 of 15')
            expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('0 of 0')
            expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
            expect(third_child.temporary_nebraska_dashboard_case.hours).to eq('4 of 18')
            expect(first_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('n/a')
            expect(second_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('2 trips - $22.00')
            expect(third_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('n/a')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            first_child.destroy!
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            described_class.new(dashboard_csv).call
          end
        end
        context 'when the csv data is the wrong format from a file' do
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }
          it 'returns false' do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            expect(described_class.new(invalid_csv).call).to eq(false)
          end
        end

        context 'when the csv data is the wrong format from a string' do
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }
          it 'returns false' do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            expect(described_class.new("wrong_headers,icon,face\nnope,yep,maybe").call).to eq(false)
          end
        end

        context 'when the csv data is the wrong format from a stream' do
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }
          it 'returns false' do
            expect(stubbed_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            expect(described_class.new(StringIO.new("wrong_headers,icon,face\nnope,yep,maybe")).call).to eq(false)
          end
        end
      end
    end
  end
end
