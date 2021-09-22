# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe DashboardCaseImporter do
      let!(:file_name) { 'file_name.csv' }
      let!(:source_bucket) { 'source_bucket' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:stubbed_client) { double('AwsClient') }

      let!(:dashboard_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data.csv')) }
      let!(:invalid_csv) { File.read(Rails.root.join('spec/fixtures/files/invalid_format.csv')) }
      let!(:missing_field_csv) do
        File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data_missing_field.csv'))
      end
      let!(:parsed_valid_csv) { CsvParser.new(dashboard_csv).call }

      let!(:business) { create(:business, name: 'Test Day Care') }
      let!(:first_child) { create(:necc_child, full_name: 'Sarah Brighton', business: business) }
      let!(:second_child) { create(:necc_child, full_name: 'Charles Williamson', business: business) }
      let!(:third_child) { create(:necc_child, full_name: 'Marcus Wright', business: business) }

      before do
        allow(Rails.application.config).to receive(:aws_necc_dashboard_bucket) { source_bucket }
        allow(Rails.application.config).to receive(:aws_necc_dashboard_archive_bucket) { archive_bucket }
        allow(AwsClient).to receive(:new) { stubbed_client }
        allow(stubbed_client).to receive(:list_file_names).with(source_bucket) { [file_name] }
      end

      describe '#call' do
        context 'with valid data' do
          before do
            allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { dashboard_csv }
            allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
          end

          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new.call }.to change(TemporaryNebraskaDashboardCase, :count).from(0).to(3)
            expect { described_class.new.call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            children = [first_child, second_child, third_child]
            described_class.new.call
            children.each_with_index do |child, idx|
              expect(child.temporary_nebraska_dashboard_case).to have_attributes(
                as_of: parsed_valid_csv[idx]['As of Date'].strftime('%Y-%m-%d'),
                attendance_risk: parsed_valid_csv[idx]['Status'],
                absences: parsed_valid_csv[idx]['Absences'],
                earned_revenue: parsed_valid_csv[idx]['Earned revenue'],
                estimated_revenue: parsed_valid_csv[idx]['Estimated Revenue'],
                family_fee: parsed_valid_csv[idx]['Family Fee'].to_d,
                full_days: parsed_valid_csv[idx]['Full Days'],
                hours: parsed_valid_csv[idx]['Hourly'],
                hours_attended: parsed_valid_csv[idx]['Hours Attended']
              )
            end
          end
        end

        it "continues processing and archives if the child doesn't exist" do
          allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { dashboard_csv }
          allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
          first_child.destroy!
          children = [first_child, second_child, third_child]
          expect { described_class.new.call }.to change(TemporaryNebraskaDashboardCase, :count).from(0).to(2)
          expect { described_class.new.call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          children.each_with_index do |child, idx|
            next if idx == 0 # we deleted the first kid!

            expect(child.temporary_nebraska_dashboard_case).to have_attributes(
              as_of: parsed_valid_csv[idx]['As of Date'].strftime('%Y-%m-%d'),
              attendance_risk: parsed_valid_csv[idx]['Status'],
              absences: parsed_valid_csv[idx]['Absences'],
              earned_revenue: parsed_valid_csv[idx]['Earned revenue'],
              estimated_revenue: parsed_valid_csv[idx]['Estimated Revenue'],
              family_fee: parsed_valid_csv[idx]['Family Fee'].to_d,
              full_days: parsed_valid_csv[idx]['Full Days'],
              hours: parsed_valid_csv[idx]['Hourly'],
              hours_attended: parsed_valid_csv[idx]['Hours Attended']
            )
          end
        end

        it 'continues processing if the record is invalid or missing a required field' do
          allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { invalid_csv }
          allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
          expect { described_class.new.call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          expect(first_child.temporary_nebraska_dashboard_case).to be_nil
          expect(second_child.temporary_nebraska_dashboard_case).to be_nil
          expect(third_child.temporary_nebraska_dashboard_case).to be_nil
          allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { missing_field_csv }
          allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
          expect { described_class.new.call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          expect(first_child.temporary_nebraska_dashboard_case).to be_nil
          expect(second_child.temporary_nebraska_dashboard_case).to be_nil
          expect(third_child.temporary_nebraska_dashboard_case).to be_nil
        end
      end
    end
  end
end
