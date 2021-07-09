# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe DashboardCsvImporter do
      let!(:file_name) { 'file_name.csv' }
      let!(:source_bucket) { 'source_bucket' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:akid) { 'akid' }
      let!(:secret) { 'secret' }
      let!(:region) { 'region' }
      let!(:action) { 'action' }
      let!(:stubbed_client) { double('AWS Client') }
      let!(:stubbed_object) { double('S3 Object') }

      let!(:dashboard_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data.csv')) }
      let!(:invalid_csv) { File.read(Rails.root.join('spec/fixtures/files/invalid_format.csv')) }
      let!(:missing_field_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data_missing_field.csv')) }

      let!(:business) { create(:business, name: 'Test Day Care') }
      let!(:first_child) { create(:necc_child, full_name: 'Sarah Brighton', business: business) }
      let!(:second_child) { create(:necc_child, full_name: 'Charles Williamson', business: business) }
      let!(:third_child) { create(:necc_child, full_name: 'Marcus Wright', business: business) }

      before(:each) do
        allow(Rails.application.config).to receive(:aws_access_key_id).and_return(akid)
        allow(Rails.application.config).to receive(:aws_secret_access_key).and_return(secret)
        allow(Rails.application.config).to receive(:aws_access_key_id).and_return(akid)
        allow(Rails.application.config).to receive(:aws_region).and_return(region)
        allow(Aws::S3::Client).to receive(:new) { stubbed_client }
        allow_any_instance_of(described_class).to receive(:source_bucket).and_return(source_bucket)
        allow_any_instance_of(described_class).to receive(:archive_bucket).and_return(archive_bucket)
        allow(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
        allow(stubbed_client).to receive(:get_object).and_return(stubbed_object)
      end

      describe '#call' do
        context 'with valid data' do
          before(:each) do
            allow(stubbed_object).to receive(:body).and_return(dashboard_csv)
            allow(stubbed_client).to receive(:copy_object).and_return({ copy_object_result: {} })
            allow(stubbed_client).to receive(:delete_object).and_return({})
          end

          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new.call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
            allow(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
            allow(stubbed_client).to receive(:get_object).and_return(stubbed_object)
            allow(stubbed_object).to receive(:body).and_return(dashboard_csv)
            allow(stubbed_client).to receive(:copy_object).and_return({ copy_object_result: {} })
            allow(stubbed_client).to receive(:delete_object).and_return({})
            expect { described_class.new.call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            described_class.new.call
            expect(first_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-21')
            expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('1 of 3')
            expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
            expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('0')
            expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('90.77')
            expect(first_child.temporary_nebraska_dashboard_case.family_fee).to eq(120.00)
            expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('0 of 20')
            expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('0 of 0')
            expect(first_child.temporary_nebraska_dashboard_case.hours_attended).to eq('4 of 6')
            expect(second_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-25')
            expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('3 of 4')
            expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
            expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
            expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
            expect(second_child.temporary_nebraska_dashboard_case.family_fee).to eq(25.00)
            expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
            expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
            expect(second_child.temporary_nebraska_dashboard_case.hours_attended).to eq('1 of 2')
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

        it "continues processing if the child doesn't exist" do
          allow(stubbed_object).to receive(:body).and_return(dashboard_csv)
          first_child.destroy!
          described_class.new.call
          expect(stubbed_client).not_to receive(:copy_object)
          expect(stubbed_client).not_to receive(:delete_object)
        end

        it 'continues processing if the record is invalid or missing a required field' do
          allow(stubbed_object).to receive(:body).and_return(invalid_csv)
          described_class.new.call
          expect(stubbed_client).not_to receive(:copy_object)
          expect(stubbed_client).not_to receive(:delete_object)
          allow(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
          allow(stubbed_client).to receive(:get_object).and_return(stubbed_object)
          allow(stubbed_object).to receive(:body).and_return(missing_field_csv)
          described_class.new.call
          expect(stubbed_client).not_to receive(:copy_object)
          expect(stubbed_client).not_to receive(:delete_object)
        end
      end
    end
  end
end
