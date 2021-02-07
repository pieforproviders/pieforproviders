# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WonderschoolNeccAttendanceReader do
  let!(:attendance_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data.csv') }
  let!(:first_child) { create(:necc_child, wonderschool_id: '123456789') }
  let!(:second_child) { create(:necc_child, wonderschool_id: '987654321') }
  let!(:third_child) { create(:necc_child, wonderschool_id: '121212121') }

  describe '.call' do
    it "returns nil for a file that doesn't exist" do
      expect(described_class.new(Rails.root.join('fake.csv')).call).to be_nil
    end

    it 'creates attendance records for every row in the file, idempotently' do
      expect { described_class.new(attendance_csv).call }.to change { Attendance.count }.from(0).to(3)
      expect { described_class.new(attendance_csv).call }.not_to change(Attendance, :count)
    end

    it 'creates attendance records for the correct child with the correct data' do
      described_class.new(attendance_csv).call
      expect(
        first_child.attendances.first.check_in.in_time_zone(first_child.timezone)
      ).to be_within(1.second).of 'Sat, 06 Feb 2021 07:59:49AM'.in_time_zone(first_child.timezone)
      expect(
        first_child.attendances.first.check_out.in_time_zone(first_child.timezone)
      ).to be_within(1.second).of 'Sat, 06 Feb 2021 12:12:03PM'.in_time_zone(first_child.timezone)
      expect(
        second_child.attendances.first.check_in.in_time_zone(second_child.timezone)
      ).to be_within(1.second).of 'Wed, 03 Feb 2021 03:56:09PM'.in_time_zone(second_child.timezone)
      expect(
        second_child.attendances.first.check_out.in_time_zone(second_child.timezone)
      ).to be_within(1.second).of 'Thu, 04 Feb 2021 01:56:44AM'.in_time_zone(second_child.timezone)
      expect(
        third_child.attendances.first.check_in.in_time_zone(third_child.timezone)
      ).to be_within(1.second).of 'Fri, 05 Feb 2021 07:57:35AM'.in_time_zone(third_child.timezone)
      expect(
        third_child.attendances.first.check_out.in_time_zone(third_child.timezone)
      ).to be_within(1.second).of 'Fri, 05 Feb 2021 04:21:23PM'.in_time_zone(third_child.timezone)
    end

    it "does not stop the job if the child doesn't exist, and logs the failed child" do
      first_child.destroy!
      expect(Rails.logger).to receive(:tagged).and_yield
      expect(Rails.logger).to receive(:error).with([
        CSV::Row.new(
          %w[child_id checked_in_at checked_out_at],
          ['123456789', 'Sat, 06 Feb 2021 07:59:49AM', 'Sat, 06 Feb 2021 12:12:03PM']
        )
      ].to_s)
      described_class.new(attendance_csv).call
    end
  end
end
