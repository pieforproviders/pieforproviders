# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe AttendanceCsvImporter do
      let!(:file_name) { 'file_name.csv' }
      let!(:source_bucket) { 'source_bucket' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:akid) { 'akid' }
      let!(:secret) { 'secret' }
      let!(:region) { 'region' }
      let!(:action) { 'action' }
      let!(:stubbed_client) { double('AWS Client') }
      let!(:stubbed_object) { double('S3 Object') }

      let!(:attendance_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data.csv')) }
      let!(:invalid_csv) { File.read(Rails.root.join('spec/fixtures/files/invalid_format.csv')) }
      let!(:missing_field_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data_missing_field.csv')) }

      let!(:business1) { create(:business, name: 'Test Daycare') }
      let!(:business2) { create(:business, name: 'Fake Daycare') }
      let!(:first_child) do
        create(:necc_child,
               wonderschool_id: '1234',
               business: business1,
               approvals: [create(:approval, effective_on: Date.parse('November 28, 2020'), create_children: false)])
      end
      let!(:second_child) do
        create(:necc_child,
               wonderschool_id: '5678',
               business: business2,
               approvals: [create(:approval, effective_on: Date.parse('November 28, 2020'), create_children: false)])
      end
      let!(:third_child) do
        create(:necc_child,
               wonderschool_id: '5677',
               business: business2,
               approvals: [create(:approval, effective_on: Date.parse('November 28, 2020'), create_children: false)])
      end

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
            allow(stubbed_object).to receive(:body).and_return(attendance_csv)
            allow(stubbed_client).to receive(:copy_object).and_return({ copy_object_result: {} })
            allow(stubbed_client).to receive(:delete_object).and_return({})
          end

          it 'creates attendance records for every row in the file, idempotently' do
            expect { described_class.new.call }.to change { Attendance.count }.from(0).to(8)
            allow(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
            allow(stubbed_client).to receive(:get_object).and_return(stubbed_object)
            allow(stubbed_object).to receive(:body).and_return(attendance_csv)
            allow(stubbed_client).to receive(:copy_object).and_return({ copy_object_result: {} })
            allow(stubbed_client).to receive(:delete_object).and_return({})
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
          allow(stubbed_object).to receive(:body).and_return(attendance_csv)
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
