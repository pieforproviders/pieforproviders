# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe AttendanceProcessor do
      let!(:attendance_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data.csv') }
      let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data_invalid_format.csv') }
      let!(:valid_string) do
        "child_id,checked_in_at,checked_out_at\n"\
        "123456789,\"Sat, 06 Feb 2021 07:59:49AM\",\"Sat, 06 Feb 2021 12:12:03PM\"\n"\
        "987654321,\"Wed, 03 Feb 2021 03:56:09PM\",\"Thu, 04 Feb 2021 01:56:44AM\"\n"\
        '121212121,"Fri, 05 Feb 2021 07:57:35AM","Fri, 05 Feb 2021 04:21:23PM"'
      end
      let!(:first_child) { create(:necc_child, wonderschool_id: '123456789') }
      let!(:second_child) { create(:necc_child, wonderschool_id: '987654321') }
      let!(:third_child) { create(:necc_child, wonderschool_id: '121212121') }

      let!(:file_name) { 'failed_attendances' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:stubbed_client) { double('AWS Client') }

      let(:error_log) do
        [
          [
            %w[child_id 123456789],
            ['checked_in_at', 'Sat, 06 Feb 2021 07:59:49AM'],
            ['checked_out_at', 'Sat, 06 Feb 2021 12:12:03PM']
          ]
        ].flatten.to_s
      end

      RSpec.shared_examples 'adds all attendances idempotently' do
        it 'creates attendance records for every row in the file, idempotently' do
          expect { described_class.new(input).call }.to change { Attendance.count }.from(0).to(3)
          expect { described_class.new(input).call }.not_to change(Attendance, :count)
        end
      end

      RSpec.shared_examples 'updates the correct records' do
        it 'creates attendance records for the correct child with the correct data' do
          described_class.new(input).call
          expect(first_child.attendances.first.check_in).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 07:59:49AM')
          expect(first_child.attendances.first.check_out).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 12:12:03PM')
          expect(second_child.attendances.first.check_in).to be_within(1.second).of DateTime.parse('Wed, 03 Feb 2021 03:56:09PM')
          expect(second_child.attendances.first.check_out).to be_within(1.second).of DateTime.parse('Thu, 04 Feb 2021 01:56:44AM')
          expect(third_child.attendances.first.check_in).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 07:57:35AM')
          expect(third_child.attendances.first.check_out).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 04:21:23PM')
        end
      end

      RSpec.shared_examples 'continues and logs errors' do
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

      RSpec.shared_examples 'invalid input returns false' do
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

      describe '.call' do
        before do
          allow(Rails.application.config).to receive(:aws_necc_attendance_archive_bucket).and_return(archive_bucket)
          allow(Aws::S3::Client).to receive(:new) { stubbed_client }
        end

        context "when a file name passed in doesn't exist" do
          it 'returns false' do
            expect(described_class.new(Rails.root.join('fake.csv')).call).to eq(false)
          end
        end

        context 'with a valid string' do
          let(:input) { valid_string }
          include_examples 'adds all attendances idempotently'
          include_examples 'updates the correct records'
          include_examples 'continues and logs errors'
        end

        context 'with a valid file' do
          let(:input) { attendance_csv }
          include_examples 'adds all attendances idempotently'
          include_examples 'updates the correct records'
          include_examples 'continues and logs errors'
        end

        context 'when the csv data is the wrong format' do
          let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }

          context 'from a string' do
            let(:invalid_input) { "wrong_headers,icon,face\nnope,yep,maybe" }
            include_examples 'invalid input returns false'
          end

          context 'from a file' do
            let(:invalid_input) { invalid_csv }
            include_examples 'invalid input returns false'
          end
        end
      end
    end
  end
end
