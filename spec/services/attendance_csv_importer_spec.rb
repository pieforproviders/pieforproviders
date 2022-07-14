# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendanceCsvImporter do
  let!(:file_name) { 'Test Child Care-Grid view.csv' }
  let!(:source_bucket) { 'source_bucket' }
  let!(:archive_bucket) { 'archive_bucket' }
  let!(:stubbed_client) { instance_double(AwsClient) }

  let!(:attendance_csv) { File.read(Rails.root.join('spec/fixtures/files/Test Child Care-Grid view.csv')) }

  # TODO: file with a name that doesn't match a business
  # TODO: file with missing required fields (check_in, check_out, full_name OR dhs_id)
  # TODO: check column names in Airtable, might need to update them to export correctly to match the script
  # TODO: file with a child that doesn't exist in user's account
  # TODO: file with a child that doesn't exist in db at all
  # TODO: file with a child w/ only DHS ID
  # TODO: file with a child w/ only Full Name
  # TODO: file with duplicate attendance to what already exists
  let!(:invalid_csv) { File.read(Rails.root.join('spec/fixtures/files/invalid_format.csv')) }
  let!(:missing_field_csv) do
    File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_attendance_data_missing_field.csv'))
  end

  let!(:business1) { create(:business, name: 'Test Child Care') }
  let!(:business2) { create(:business, name: 'Fake Daycare') }
  let!(:approvals) do
    create_list(:approval,
                4,
                effective_on: Time.zone.parse('November 28, 2020'),
                expires_on: nil,
                create_children: false)
  end
  let!(:hermione_business1) do
    create(:necc_child,
           first_name: 'Hermione',
           last_name: 'Granger',
           dhs_id: '1234',
           business: business1,
           approvals: [approvals[0]])
  end
  let!(:child2_business1) do
    create(:necc_child,
           dhs_id: '5678',
           business: business1,
           approvals: [approvals[1]])
  end
  let!(:third_child) do
    create(:necc_child,
           first_name: 'Lucy',
           last_name: 'Pevensie',
           dhs_id: '5677',
           business: business1,
           approvals: [approvals[2]])
  end

  before do
    # 4th child, different business
    create(:necc_child,
           first_name: 'Hermione',
           last_name: 'Granger',
           dhs_id: '5679',
           business: business2,
           approvals: [approvals[3]])
    allow(Rails.application.config).to receive(:aws_necc_attendance_bucket) { source_bucket }
    allow(Rails.application.config).to receive(:aws_necc_attendance_archive_bucket) { archive_bucket }
    allow(AwsClient).to receive(:new) { stubbed_client }
    allow(stubbed_client).to receive(:list_file_names).with(source_bucket) { [file_name] }
  end

  describe '#call' do
    context 'with valid data' do
      before do
        allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { attendance_csv }
        allow(stubbed_client).to receive(:archive_file).with(
          source_bucket,
          archive_bucket,
          /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/
        )
      end

      it 'creates attendance records for a given date range' do
        expect { described_class.new.call('2021-03-10'.to_date, 0.days.after) }
          .to change(ServiceDay, :count).from(0).to(4)
          .and change(Attendance, :count).from(0).to(2)
        expect(third_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.in_time_zone(third_child.timezone)
        expect(third_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.in_time_zone(third_child.timezone)
        expect(hermione_business1.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.in_time_zone(hermione_business1.timezone)
        expect(hermione_business1.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.in_time_zone(hermione_business1.timezone)
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
        expect(hermione_business1.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-05 5:14am'.in_time_zone(hermione_business1.timezone)
        expect(hermione_business1.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-05 12:23pm'.in_time_zone(hermione_business1.timezone)
        expect(child2_business1.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-02-24 6:04am'.in_time_zone(child2_business1.timezone)
        expect(child2_business1.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-02-24 4:35pm'.in_time_zone(child2_business1.timezone)
        expect(third_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of '2021-03-10 6:54am'.in_time_zone(third_child.timezone)
        expect(third_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of '2021-03-10 6:27pm'.in_time_zone(third_child.timezone)
      end
    end

    it "continues processing if the child doesn't exist" do
      allow(Rails.logger).to receive(:tagged).and_yield
      allow(Rails.logger).to receive(:info)
      hermione_business1.destroy!
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { attendance_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket,
                                                           archive_bucket,
                                                           /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(attendance_csv).call)
      described_class.new.call

      # rubocop:disable Layout/LineLength
      regex = /Business: [0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12} - child record for attendance not found \(dhs_id:( | ([^,]*)), check_in:( | (19|20)\d{2,2}-\d{1,2}-\d{2,2} \d{1,2}:\d{2,2}(a|p)m), check_out:( | (19|20)\d{2,2}-\d{1,2}-\d{2,2} \d{1,2}:\d{2,2}(a|p)m), absence:( absence| covid_absence| )\); skipping/
      # rubocop:enable Layout/LineLength

      expect(Rails.logger).to have_received(:info).with(regex).exactly(6).times
    end

    it 'continues processing if the record is invalid or missing a required field' do
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { invalid_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket,
                                                           archive_bucket,
                                                           /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(invalid_csv).call)
      described_class.new.call
      expect(hermione_business1.attendances).to be_empty
      expect(child2_business1.attendances).to be_empty
      expect(third_child.attendances).to be_empty
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { missing_field_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket,
                                                           archive_bucket,
                                                           /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]*(\d{4}|UTC)/)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(missing_field_csv).call)
      described_class.new.call
      expect(hermione_business1.attendances).to be_empty
      expect(child2_business1.attendances).to be_empty
      expect(third_child.attendances).to be_empty
    end
  end
end
