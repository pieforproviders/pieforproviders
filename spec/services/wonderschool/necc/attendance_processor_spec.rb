# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe AttendanceProcessor do
      let!(:valid_string) do
        <<~CSV
          attendance_id,child_id,school_name,checked_in_at,checked_out_at
          5772c9a6-c675-47e0-b8a3-923e076210f5,1234,Test Daycare,2020-12-03 11:23:14+00,
          0522fe23-3daa-465f-afd4-e23c01f6e11e,5678,Fake Daycare,2021-02-24 12:04:58+00,2021-02-24 22:35:29+00
          dc3e6cfe-2dbc-4f16-a8e6-bd202e8600b5,5678,Fake Daycare,2021-03-03 11:41:59+00,2021-03-03 13:06:59+00
          a245d254-be43-4635-9708-c3b8fb6e3dba,1234,Test Daycare,2021-03-04 12:39:08+00,2021-03-04 19:59:28+00
          24a846d4-b373-43f7-8791-dc6f4df05ea6,1234,Test Daycare,2021-03-05 11:14:26+00,2021-03-05 18:23:43+00
          fb373063-4637-4c07-b5b2-d8b9a56d08df,1234,Test Daycare,2021-03-09 22:10:30+00,
          f5e8609b-d39c-4efb-b098-8eb2ccddc8b5,5677,Fake Daycare,2021-03-10 12:54:39+00,2021-03-11 00:27:53+00
          138cd832-4f35-4812-b545-b625d5155f88,5677,Fake Daycare,2021-03-11 13:12:06+00,2021-03-11 23:02:34+00
        CSV
      end
      let!(:invalid_string) do
        <<~CSV
          wrong_headers,icon,face
          nope,yep,maybe
        CSV
      end
      let!(:missing_field_string) do
        <<~CSV
          attendance_id,child_id,school_name,checked_out_at
          5772c9a6-c675-47e0-b8a3-923e076210f5,1234,Test Daycare,
          0522fe23-3daa-465f-afd4-e23c01f6e11e,5678,Fake Daycare,2021-02-24 22:35:29+00
          dc3e6cfe-2dbc-4f16-a8e6-bd202e8600b5,5678,Fake Daycare,2021-03-03 13:06:59+00
          a245d254-be43-4635-9708-c3b8fb6e3dba,1234,Test Daycare,2021-03-04 19:59:28+00
          24a846d4-b373-43f7-8791-dc6f4df05ea6,1234,Test Daycare,2021-03-05 18:23:43+00
          fb373063-4637-4c07-b5b2-d8b9a56d08df,1234,Test Daycare,
          f5e8609b-d39c-4efb-b098-8eb2ccddc8b5,5677,Fake Daycare,2021-03-11 00:27:53+00
          138cd832-4f35-4812-b545-b625d5155f88,5677,Fake Daycare,2021-03-11 23:02:34+00
        CSV
      end
      let!(:business1) { create(:business, name: 'Test Daycare') }
      let!(:business2) { create(:business, name: 'Fake Daycare') }
      let!(:first_child) { create(:necc_child, wonderschool_id: '1234', business: business1) }
      let!(:second_child) { create(:necc_child, wonderschool_id: '5678', business: business2) }
      let!(:third_child) { create(:necc_child, wonderschool_id: '5677', business: business2) }

      let!(:file_name) { 'failed_attendances' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:source_bucket) { 'source_bucket' }
      let!(:s3_client) do
        Aws::S3::Client.new(stub_responses: true)
      end

      let(:error_log) do
        [
          [
            %w[attendance_id 5772c9a6-c675-47e0-b8a3-923e076210f5],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_in_at', '2020-12-03 11:23:14+00'],
            ['checked_out_at', nil]
          ],
          [
            %w[attendance_id a245d254-be43-4635-9708-c3b8fb6e3dba],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_in_at', '2021-03-04 12:39:08+00'],
            ['checked_out_at', '2021-03-04 19:59:28+00']
          ],
          [
            %w[attendance_id 24a846d4-b373-43f7-8791-dc6f4df05ea6],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_in_at', '2021-03-05 11:14:26+00'],
            ['checked_out_at', '2021-03-05 18:23:43+00']
          ],
          [
            %w[attendance_id fb373063-4637-4c07-b5b2-d8b9a56d08df],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_in_at', '2021-03-09 22:10:30+00'],
            ['checked_out_at', nil]
          ]
        ].flatten.to_s
      end

      let(:invalid_error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }

      let(:missing_field_error_log) do
        [
          [
            %w[attendance_id 5772c9a6-c675-47e0-b8a3-923e076210f5],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_out_at', nil]
          ],
          [
            %w[attendance_id 0522fe23-3daa-465f-afd4-e23c01f6e11e],
            %w[child_id 5678],
            ['school_name', 'Fake Daycare'],
            ['checked_out_at', '2021-02-24 22:35:29+00']
          ],
          [
            %w[attendance_id dc3e6cfe-2dbc-4f16-a8e6-bd202e8600b5],
            %w[child_id 5678],
            ['school_name', 'Fake Daycare'],
            ['checked_out_at', '2021-03-03 13:06:59+00']
          ],
          [
            %w[attendance_id a245d254-be43-4635-9708-c3b8fb6e3dba],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_out_at', '2021-03-04 19:59:28+00']
          ],
          [
            %w[attendance_id 24a846d4-b373-43f7-8791-dc6f4df05ea6],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_out_at', '2021-03-05 18:23:43+00']
          ],
          [
            %w[attendance_id fb373063-4637-4c07-b5b2-d8b9a56d08df],
            %w[child_id 1234],
            ['school_name', 'Test Daycare'],
            ['checked_out_at', nil]
          ],
          [
            %w[attendance_id f5e8609b-d39c-4efb-b098-8eb2ccddc8b5],
            %w[child_id 5677],
            ['school_name', 'Fake Daycare'],
            ['checked_out_at', '2021-03-11 00:27:53+00']
          ],
          [
            %w[attendance_id 138cd832-4f35-4812-b545-b625d5155f88],
            %w[child_id 5677],
            ['school_name', 'Fake Daycare'],
            ['checked_out_at', '2021-03-11 23:02:34+00']
          ]
        ].flatten.to_s
      end

      describe '.call' do
        before do
          s3_client.stub_responses(:list_objects_v2, {
                                     contents: [{ key: 'my-file' }]
                                   })
          allow(Rails.application.config).to receive(:aws_necc_attendance_bucket).and_return(source_bucket)
          allow(Rails.application.config).to receive(:aws_necc_attendance_archive_bucket).and_return(archive_bucket)
          # allow(s3_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: 'my-file' }] })
          allow(s3_client).to receive(:get_object).and_return(valid_string)
        end

        context 'with a valid string' do
          it 'creates attendance records for every row in the CSV body, idempotently' do
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
          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            first_child.destroy!
            expect(s3_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: error_log, key: file_name
              }
            )
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(error_log)
            described_class.new.call
          end
        end

        context 'when the csv data is the wrong format' do
          it 'returns false' do
            expect(s3_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: invalid_error_log, key: file_name
              }
            )
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(invalid_error_log)
            expect(described_class.new.call).to eq(false)
          end
        end

        context 'when the csv data is missing a field' do
          it 'returns false' do
            expect(s3_client).to receive(:put_object).with(
              {
                bucket: archive_bucket,
                body: missing_field_error_log, key: file_name
              }
            )
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with(missing_field_error_log)
            expect(described_class.new.call).to eq(false)
          end
        end
      end
    end
  end
end
