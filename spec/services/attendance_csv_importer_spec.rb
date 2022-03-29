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
           full_name: 'Hermione Granger',
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
           full_name: 'Lucy Pevensie',
           first_name: 'Lucy',
           last_name: 'Pevensie',
           dhs_id: '5677',
           business: business1,
           approvals: [approvals[2]])
  end

  before do
    # 4th child, different business
    create(:necc_child,
           full_name: 'Hermione Granger',
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
        allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
      end

      it 'creates attendance records for every row in the file, idempotently' do
        expect { described_class.new.call }.to change(Attendance, :count).from(0).to(9)
        Attendance.all.map(&:reload)
        expect { described_class.new.call }.not_to change(Attendance, :count)
      end

      it 'creates attendance records for the correct child with the correct data' do
        described_class.new.call
        expect(hermione_business1.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of Time.zone.parse('2020-12-03 5:23am')
        expect(hermione_business1.attendances.order(:check_in).first.check_out).to be_nil
        expect(child2_business1.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of Time.zone.parse('2021-02-24 6:04am')
        expect(child2_business1.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of Time.zone.parse('2021-02-24 4:35pm')
        expect(third_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of Time.zone.parse('2021-03-10 6:54am')
        expect(third_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of Time.zone.parse('2021-03-10 6:27pm')
        expect(third_child.attendances.order(:check_in).first.check_in)
          .to be_within(1.minute).of Time.zone.parse('2021-03-10 6:54am')
        expect(third_child.attendances.order(:check_in).first.check_out)
          .to be_within(1.minute).of Time.zone.parse('2021-03-10 6:27pm')
      end

      it 'removes existing absences records for the correct child with the correct data' do
        create(:attendance,
               child_approval: child2_business1.child_approvals.first,
               check_in: Time.zone.parse('2021-02-24'),
               check_out: nil,
               absence: 'absence')
        expect(child2_business1.attendances.for_day(Time.zone.parse('2021-02-24')).length).to eq(1)
        expect(child2_business1.attendances.for_day(Time.zone.parse('2021-02-24')).absences.length).to eq(1)
        child2_business1.reload
        described_class.new.call
        expect(child2_business1.attendances.for_day(Time.zone.parse('2021-02-24')).length).to eq(1)
        expect(child2_business1.attendances.for_day(Time.zone.parse('2021-02-24')).absences.length).to eq(0)
      end
    end

    it "continues processing if the child doesn't exist" do
      allow(Rails.logger).to receive(:tagged).and_yield
      allow(Rails.logger).to receive(:info)
      hermione_business1.destroy!
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { attendance_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(attendance_csv).call)
      described_class.new.call
      expect(Rails.logger).to have_received(:tagged).exactly(10).times

      # rubocop:disable Layout/LineLength
      regex = /Business: [0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12} - child record for attendance not found \(check_in:( | (19|20)\d{2,2}-\d{1,2}-\d{2,2} \d{1,2}:\d{2,2}(a|p)m), check_out:( | (19|20)\d{2,2}-\d{1,2}-\d{2,2} \d{1,2}:\d{2,2}(a|p)m), absence:( absence| covid_absence| )\); skipping/
      # rubocop:enable Layout/LineLength

      expect(Rails.logger).to have_received(:info).with(regex).exactly(6).times
    end

    it 'continues processing if the record is invalid or missing a required field' do
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { invalid_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
      allow(stubbed_client)
        .to receive(:archive_contents)
        .with(archive_bucket, anything, CsvParser.new(invalid_csv).call)
      described_class.new.call
      expect(hermione_business1.attendances).to be_empty
      expect(child2_business1.attendances).to be_empty
      expect(third_child.attendances).to be_empty
      allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { missing_field_csv }
      allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
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
