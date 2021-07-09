# frozen_string_literal: true

require 'rails_helper'

RSpec.describe S3CsvImporter, type: :service do
  let!(:file_name) { 'file_name.csv' }
  let!(:other_file_name) { 'other_file_name.csv' }
  let!(:source_bucket) { 'source_bucket' }
  let!(:archive_bucket) { 'archive_bucket' }
  let!(:akid) { 'akid' }
  let!(:secret) { 'secret' }
  let!(:region) { 'region' }
  let!(:action) { 'action' }
  let!(:stubbed_client) { double('AWS Client') }
  let!(:attendance_data) { "child_id,checked_in_at,checked_out_at\n123456789,\"Sat, 06 Feb 2021 07:59:49AM\",\"Sat, 06 Feb 2021 12:12:03PM\"" }
  let!(:stubbed_object) { double('S3 Object') }

  describe '#call' do
    # The implementation of the S3 CSV Importer requires the child
    # classes to define the location of the source and archive buckets
    # and how the specific file will be processed, so we're creating
    # a dummy class here to serve that purpose so we can test the implementation
    # of the parent class.  If there is a better way to do this, I'd be interested
    # to hear about it.
    let(:child_class) do
      Class.new(described_class) do
        def source_bucket
          'source_bucket'
        end

        def archive_bucket
          'archive_bucket'
        end

        def process_row(_row)
          true
        end
      end
    end
    before(:each) do
      allow(Rails.application.config).to receive(:aws_access_key_id).and_return(akid)
      allow(Rails.application.config).to receive(:aws_secret_access_key).and_return(secret)
      allow(Rails.application.config).to receive(:aws_access_key_id).and_return(akid)
      allow(Rails.application.config).to receive(:aws_region).and_return(region)
      allow(Aws::S3::Client).to receive(:new) { stubbed_client }
    end

    context 'when a single file is present on the S3 bucket' do
      it 'archives the file when it is successfully processed' do
        expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
        expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).and_return(attendance_data)
        allow_any_instance_of(child_class).to receive(:process_row).and_return(true)
        expect(stubbed_client).to receive(:copy_object).with(
          {
            bucket: archive_bucket,
            copy_source: "#{source_bucket}/#{file_name}", key: file_name
          }
        ).and_return({ copy_object_result: {} })
        expect(stubbed_client).to receive(:delete_object).with({ bucket: source_bucket, key: file_name }).and_return({})
        child_class.new.call
      end
      it 'does not archive the file when the CSV is malformed' do
        expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
        expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).and_return('malformed')
        expect_any_instance_of(child_class).not_to receive(:process_row)
        expect(stubbed_client).not_to receive(:copy_object)
        expect(stubbed_client).not_to receive(:delete_object)
        child_class.new.call
      end
      it 'does not archive the file when it fails processing' do
        expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
        expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).and_return(attendance_data)
        allow_any_instance_of(child_class).to receive(:process_row).and_return(false)
        expect(stubbed_client).not_to receive(:copy_object)
        expect(stubbed_client).not_to receive(:delete_object)
        child_class.new.call
      end
    end

    context 'when there are multiple files in the S3 bucket' do
      it 'when all the files have valid data, it archives them all' do
        expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }, { key: other_file_name }] })
        expect(stubbed_client).to receive(:get_object).twice.and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).twice.and_return(attendance_data)
        allow_any_instance_of(child_class).to receive(:process_row).and_return(true)
        expect(stubbed_client).to receive(:copy_object).twice.and_return({ copy_object_result: {} })
        expect(stubbed_client).to receive(:delete_object).twice.and_return({})
        child_class.new.call
      end
      it 'when one of the files has no valid data, it does not archive the failed file' do
        expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }, { key: other_file_name }] })

        expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).and_return(attendance_data)
        allow_any_instance_of(child_class).to receive(:process_row).and_return(true)
        expect(stubbed_client).to receive(:copy_object).with(
          {
            bucket: archive_bucket,
            copy_source: "#{source_bucket}/#{file_name}", key: file_name
          }
        ).and_return({ copy_object_result: {} })
        expect(stubbed_client).to receive(:delete_object).with({ bucket: source_bucket, key: file_name }).and_return({})

        expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: other_file_name }).and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).and_return('malformed')
        expect_any_instance_of(child_class).to receive(:process_row).once
        expect(stubbed_client).not_to receive(:copy_object)
        expect(stubbed_client).not_to receive(:delete_object)
        child_class.new.call
      end
      it 'when one of the files has failed rows, does not archive the file with failed rows' do
        expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }, { key: other_file_name }] })

        expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).and_return(attendance_data)
        allow_any_instance_of(child_class).to receive(:process_row).and_return(true, false)
        expect(stubbed_client).to receive(:copy_object).with(
          {
            bucket: archive_bucket,
            copy_source: "#{source_bucket}/#{file_name}", key: file_name
          }
        ).and_return({ copy_object_result: {} })
        expect(stubbed_client).to receive(:delete_object).with({ bucket: source_bucket, key: file_name }).and_return({})

        expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: other_file_name }).and_return(stubbed_object)
        expect(stubbed_object).to receive(:body).and_return(attendance_data)
        expect(stubbed_client).not_to receive(:copy_object)
        expect(stubbed_client).not_to receive(:delete_object)
        child_class.new.call
      end
    end

    context "when there's no file in the S3 bucket" do
      it 'raises a no files found error' do
        allow(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [] })
        expect(stubbed_client).not_to receive(:get_object)
        expect(stubbed_object).not_to receive(:body)
        expect(stubbed_client).not_to receive(:copy_object)
        expect(stubbed_client).not_to receive(:delete_object)
        expect { child_class.new.call }.to raise_error(S3CsvImporter::NoFilesFoundError)
      end
    end
  end
end
