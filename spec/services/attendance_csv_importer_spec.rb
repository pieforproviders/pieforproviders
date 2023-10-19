# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendanceCsvImporter do
  let!(:file_name) { 'Test Child Care.csv' }
  let!(:source_bucket) { 'source_bucket' }
  let!(:archive_bucket) { 'archive_bucket' }
  let!(:stubbed_client) { instance_double(AwsClient) }

  let!(:attendance_csv) { Rails.root.join('spec/fixtures/files/Test Child Care.csv').read }

  # TODO: file with a name that doesn't match a business
  # TODO: file with missing required fields (check_in, check_out, full_name OR dhs_id)
  # TODO: check column names in Airtable, might need to update them to export correctly to match the script
  # TODO: file with a child that doesn't exist in user's account
  # TODO: file with a child that doesn't exist in db at all
  # TODO: file with a child w/ only DHS ID
  # TODO: file with a child w/ only Full Name
  # TODO: file with duplicate attendance to what already exists
  let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/invalid_format.csv').read }
  let!(:missing_field_csv) do
    Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data_missing_field.csv').read
  end

  let!(:business_one) { create(:business, name: 'Test Child Care') }
  let!(:business_two) { create(:business, name: 'Fake Daycare') }
  let!(:approvals) do
    create_list(:approval,
                4,
                effective_on: Time.zone.parse('November 28, 2020'),
                expires_on: nil,
                create_children: false)
  end
  let!(:hermione_business_one) do
    child = create(:necc_child,
                   first_name: 'Hermione',
                   last_name: 'Granger',
                   dhs_id: '1234',
                   approvals: [approvals[0]])
    create(:child_business, child:, business: business_one)
    child
  end
  let!(:child2_business_one) do
    child = create(:necc_child,
                   dhs_id: '5678',
                   approvals: [approvals[1]])
    create(:child_business, child:, business: business_one)
    child
  end
  let!(:third_child) do
    child = create(:necc_child,
                   first_name: 'Lucy',
                   last_name: 'Pevensie',
                   dhs_id: '5677',
                   approvals: [approvals[2]])
    create(:child_business, child:, business: business_one)
    child
  end

  before do
    # 4th child, different business
    child = create(:necc_child,
                   first_name: 'Hermione',
                   last_name: 'Granger',
                   dhs_id: '5679',
                   approvals: [approvals[3]])
    create(:child_business, child:, business: business_two)
    allow(Rails.application.config).to receive(:aws_necc_attendance_bucket) { source_bucket }
    allow(Rails.application.config).to receive(:aws_necc_attendance_archive_bucket) { archive_bucket }
    allow(AwsClient).to receive(:new) { stubbed_client }
    allow(stubbed_client).to receive(:list_file_names).with(source_bucket, 'CSV/') { [file_name] }
  end

  describe '#call' do
    context 'with valid data' do
      before do
        allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { attendance_csv }
        allow(stubbed_client).to receive(:archive_file).with(
          source_bucket,
          archive_bucket,
          file_name,
          /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/
        )
      end

      it 'creates attendance records given a start date and no end date' do
        expect { described_class.new(start_date: '2021-03-10'.to_date).call }
          .to change(ServiceDay, :count).from(0).to(4)
          .and change(Attendance, :count).from(0).to(2)
        expect(third_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.to_datetime
        expect(third_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.to_datetime
        expect(hermione_business_one.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.to_datetime
        expect(hermione_business_one.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.to_datetime
      end

      it 'creates attendance records given an end date and no start date' do
        expect { described_class.new(end_date: '2021-02-24'.to_date).call }
          .to change(ServiceDay, :count).from(0).to(2)
          .and change(Attendance, :count).from(0).to(1)
        expect(hermione_business_one.service_days.count).to eq(1)
        expect(Child.where(dhs_id: '5678').count).to eq(1)
        fourth_child = Child.find_by(dhs_id: '5678')
        expect(fourth_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-02-24 6:04am'.to_datetime
        expect(fourth_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-02-24 4:35pm'.to_datetime
      end

      it 'creates attendance records for a given date range' do
        expect { described_class.new(start_date: '2021-03-10'.to_date, end_date: '2021-03-10'.to_date).call }
          .to change(ServiceDay, :count).from(0).to(2)
          .and change(Attendance, :count).from(0).to(2)
        expect(third_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.to_datetime
        expect(third_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.to_datetime
        expect(hermione_business_one.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.to_datetime
        expect(hermione_business_one.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.to_datetime
      end

      it 'creates attendance records for every row in the file, idempotently' do
        expect { described_class.new.call }
          .to change(ServiceDay, :count).from(0).to(9)
          .and change(Attendance, :count).from(0).to(5)
        ServiceDay.all.map(&:reload)
        expect { described_class.new.call }.to not_change(ServiceDay, :count).and not_change(Attendance, :count)
      end

      it 'creates attendance records for the correct child with the correct data' do
        described_class.new.call
        expect(hermione_business_one.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-05 5:14am'.to_datetime
        expect(hermione_business_one.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-05 12:23pm'.to_datetime
        expect(child2_business_one.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-02-24 6:04am'.to_datetime
        expect(child2_business_one.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-02-24 4:35pm'.to_datetime
        expect(third_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.to_datetime
        expect(third_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.to_datetime
      end
    end

    it "continues processing if the child doesn't exist" do
      allow(Rails.logger).to receive(:tagged).and_yield
      allow(Rails.logger).to receive(:info)
      hermione_business_one.destroy!
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { attendance_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket,
                                                           archive_bucket,
                                                           file_name,
                                                           /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(attendance_csv).call)
      described_class.new.call

      expect(Rails.logger).to have_received(:info).exactly(4).times
    end

    it 'continues processing if the record is invalid or missing a required field' do
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { invalid_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket,
                                                           archive_bucket,
                                                           file_name,
                                                           /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(invalid_csv).call)
      described_class.new.call
      expect(hermione_business_one.attendances).to be_empty
      expect(child2_business_one.attendances).to be_empty
      expect(third_child.attendances).to be_empty
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { missing_field_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket,
                                                           archive_bucket,
                                                           file_name,
                                                           /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(missing_field_csv).call)
      described_class.new.call
      expect(hermione_business_one.attendances).to be_empty
      expect(child2_business_one.attendances).to be_empty
      expect(third_child.attendances).to be_empty
    end
  end
end
