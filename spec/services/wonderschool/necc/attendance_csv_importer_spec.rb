# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe AttendanceCsvImporter do
      let!(:uri) { 'uri' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:stubbed_client) { double('AwsClient') }
      let!(:stubbed_uri) { double('URI') }
      let!(:stubbed_csv_parser) { double('CsvParser') }

      let!(:attendance_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data.csv')) }
      let!(:invalid_csv) { File.read(Rails.root.join('spec/fixtures/files/invalid_format.csv')) }
      let!(:missing_field_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data_missing_field.csv')) }

      let!(:business1) { create(:business, name: 'Test Daycare') }
      let!(:business2) { create(:business, name: 'Fake Daycare') }
      let!(:first_child) do
        create(:necc_child,
               wonderschool_id: '1234',
               business: business1,
               approvals: [create(:approval, effective_on: Date.parse('November 28, 2020'), expires_on: nil, create_children: false)])
      end
      let!(:second_child) do
        create(:necc_child,
               wonderschool_id: '5678',
               business: business2,
               approvals: [create(:approval, effective_on: Date.parse('November 28, 2020'), expires_on: nil, create_children: false)])
      end
      let!(:third_child) do
        create(:necc_child,
               wonderschool_id: '5677',
               business: business2,
               approvals: [create(:approval, effective_on: Date.parse('November 28, 2020'), expires_on: nil, create_children: false)])
      end

      before(:each) do
        allow(Rails.application.config).to receive(:wonderschool_attendance_url).and_return(uri)
        allow(Rails.application.config).to receive(:aws_necc_attendance_archive_bucket) { archive_bucket }
        allow(AwsClient).to receive(:new) { stubbed_client }
        allow(URI).to receive(:parse).with(uri) { stubbed_uri }
        allow(stubbed_uri).to receive(:open) { attendance_csv }
      end

      describe '#call' do
        context 'with valid data' do
          before do
            allow(stubbed_client)
              .to receive(:archive_contents)
              .with(archive_bucket, anything, CsvParser.new(attendance_csv).call)
          end

          it 'creates attendance records for every row in the file, idempotently' do
            expect { described_class.new.call }.to change { Attendance.count }.from(0).to(8)
            expect { described_class.new.call }.not_to change(Attendance, :count)
          end

          it 'creates attendance records for the correct child with the correct data' do
            described_class.new.call
            expect(first_child.attendances.order(:check_in).first.check_in).to be_within(1.second).of Time.zone.parse('2020-12-03 11:23:14+00')
            expect(first_child.attendances.order(:check_in).first.check_out).to be_nil
            expect(second_child.attendances.order(:check_in).first.check_in).to be_within(1.second).of Time.zone.parse('2021-02-24 12:04:58+00')
            expect(second_child.attendances.order(:check_in).first.check_out).to be_within(1.second).of Time.zone.parse('2021-02-24 22:35:29+00')
            expect(third_child.attendances.order(:check_in).first.check_in).to be_within(1.second).of Time.zone.parse('2021-03-10 12:54:39+00')
            expect(third_child.attendances.order(:check_in).first.check_out).to be_within(1.second).of Time.zone.parse('2021-03-11 00:27:53+00')
          end
        end

        it "continues processing if the child doesn't exist" do
          first_child.destroy!
          expect(Rails.logger).to receive(:tagged).and_yield.exactly(4).times
          expect(Rails.logger).to receive(:info).with('Child with Wonderschool ID 1234 not in Pie; skipping').exactly(4).times
          allow(stubbed_client)
            .to receive(:archive_contents)
            .with(archive_bucket, anything, CsvParser.new(attendance_csv).call)
          described_class.new.call
        end

        it 'continues processing if the record is invalid or missing a required field' do
          allow(stubbed_uri).to receive(:open) { invalid_csv }
          allow(stubbed_client)
            .to receive(:archive_contents)
            .with(archive_bucket, anything, CsvParser.new(invalid_csv).call)
          described_class.new.call
          expect(first_child.attendances).to be_empty
          expect(second_child.attendances).to be_empty
          expect(third_child.attendances).to be_empty
          allow(stubbed_uri).to receive(:open) { missing_field_csv }
          allow(stubbed_client)
            .to receive(:archive_contents)
            .with(archive_bucket, anything, CsvParser.new(missing_field_csv).call)
          described_class.new.call
          expect(first_child.attendances).to be_empty
          expect(second_child.attendances).to be_empty
          expect(third_child.attendances).to be_empty
        end
      end
    end
  end
end
