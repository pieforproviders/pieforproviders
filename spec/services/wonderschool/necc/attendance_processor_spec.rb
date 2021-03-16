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

      describe '.call' do
        context "when a file name passed in doesn't exist" do
          it 'returns false' do
            expect(described_class.new(Rails.root.join('fake.csv')).call).to eq(false)
          end
        end

        context 'with a valid string' do
          it 'creates attendance records for every row in the file, idempotently' do
            expect { described_class.new(valid_string).call }.to change { Attendance.count }.from(0).to(3)
            expect { described_class.new(valid_string).call }.not_to change(Attendance, :count)
          end

          it 'creates attendance records for the correct child with the correct data' do
            described_class.new(valid_string).call
            expect(
              first_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 07:59:49AM')
            expect(
              first_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 12:12:03PM')
            expect(
              second_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Wed, 03 Feb 2021 03:56:09PM')
            expect(
              second_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Thu, 04 Feb 2021 01:56:44AM')
            expect(
              third_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 07:57:35AM')
            expect(
              third_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 04:21:23PM')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            first_child.destroy!
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[child_id 123456789], ['checked_in_at', 'Sat, 06 Feb 2021 07:59:49AM'],
                                                           ['checked_out_at', 'Sat, 06 Feb 2021 12:12:03PM']]])
            described_class.new(valid_string).call
          end
        end

        context 'with a valid stream' do
          it 'creates attendance records for every row in the file, idempotently' do
            expect { described_class.new(StringIO.new(valid_string)).call }.to change { Attendance.count }.from(0).to(3)
            expect { described_class.new(StringIO.new(valid_string)).call }.not_to change(Attendance, :count)
          end

          it 'creates attendance records for the correct child with the correct data' do
            described_class.new(StringIO.new(valid_string)).call
            expect(
              first_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 07:59:49AM')
            expect(
              first_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 12:12:03PM')
            expect(
              second_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Wed, 03 Feb 2021 03:56:09PM')
            expect(
              second_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Thu, 04 Feb 2021 01:56:44AM')
            expect(
              third_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 07:57:35AM')
            expect(
              third_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 04:21:23PM')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            first_child.destroy!
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[child_id 123456789], ['checked_in_at', 'Sat, 06 Feb 2021 07:59:49AM'],
                                                           ['checked_out_at', 'Sat, 06 Feb 2021 12:12:03PM']]])
            described_class.new(StringIO.new(valid_string)).call
          end
        end

        context 'with a valid file' do
          it 'creates attendance records for every row in the file, idempotently' do
            expect { described_class.new(attendance_csv).call }.to change { Attendance.count }.from(0).to(3)
            expect { described_class.new(attendance_csv).call }.not_to change(Attendance, :count)
          end

          it 'creates attendance records for the correct child with the correct data' do
            described_class.new(attendance_csv).call
            expect(
              first_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 07:59:49AM')
            expect(
              first_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Sat, 06 Feb 2021 12:12:03PM')
            expect(
              second_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Wed, 03 Feb 2021 03:56:09PM')
            expect(
              second_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Thu, 04 Feb 2021 01:56:44AM')
            expect(
              third_child.attendances.first.check_in
            ).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 07:57:35AM')
            expect(
              third_child.attendances.first.check_out
            ).to be_within(1.second).of DateTime.parse('Fri, 05 Feb 2021 04:21:23PM')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            first_child.destroy!
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[child_id 123456789], ['checked_in_at', 'Sat, 06 Feb 2021 07:59:49AM'],
                                                           ['checked_out_at', 'Sat, 06 Feb 2021 12:12:03PM']]])
            described_class.new(attendance_csv).call
          end
        end
        context 'when the csv data is the wrong format from a file' do
          it 'returns false' do
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]])
            expect(described_class.new(invalid_csv).call).to eq(false)
          end
        end
        context 'when the csv data is the wrong format from a string' do
          it 'returns false' do
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]])
            expect(described_class.new("wrong_headers,icon,face\nnope,yep,maybe").call).to eq(false)
          end
        end
        context 'when the csv data is the wrong format from a stream' do
          it 'returns false' do
            allow(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]])
            expect(described_class.new(StringIO.new("wrong_headers,icon,face\nnope,yep,maybe")).call).to eq(false)
          end
        end
      end
    end
  end
end
