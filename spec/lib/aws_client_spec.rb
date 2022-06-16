# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AwsClient do
  let(:s3_client) { Aws::S3::Client.new(stub_responses: true) }
  let(:appsignal_reporting_double) { instance_double(AppsignalReporting) }

  before do
    allow(appsignal_reporting_double).to receive(:send_appsignal_error)
    allow(Aws::S3::Client).to receive(:new).and_return(s3_client)
  end

  describe 'authorization' do
    it 'creates a client instance when credentials are correct' do
      expect(described_class.new.instance_variable_get(:@client)).to eq(s3_client)
    end
  end

  describe '#find_bucket' do
    it 'returns the bucket name if it is found' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'bucket' }])
      expect(described_class.new.find_bucket(name: 'bucket')).to be_truthy
    end

    it 'raises a NoBucketFound if the bucket is not found' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'peanutbutter' }])
      instance = described_class.new
      allow(instance).to receive(:send_appsignal_error)
      instance.find_bucket(name: 'bucket')
      expect(instance).to have_received(:send_appsignal_error)
        .with(
          action: 'aws-find-bucket',
          exception: described_class::NoBucketFound,
          namespace: nil,
          metadata: { name: 'bucket' }
        )
    end

    it 'raises a NoBucketFound and namespaces correctly if the bucket is not found on a tech_only call' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'peanutbutter' }])
      instance = described_class.new
      allow(instance).to receive(:send_appsignal_error)
      instance.find_bucket(name: 'bucket', tech_only: true)
      expect(instance).to have_received(:send_appsignal_error)
        .with(
          action: 'aws-find-bucket',
          exception: described_class::NoBucketFound,
          namespace: 'tech-support',
          metadata: { name: 'bucket' }
        )
    end
  end

  describe '#list_file_names' do
    it 'returns a list of file names if the bucket is not empty' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'bucket' }])
      s3_client.stub_responses(:list_objects_v2, name: 'bucket', contents: [{ key: 'key' }])
      expect(described_class.new.list_file_names('bucket')).to eq(['key'])
    end

    it 'raises a NoFilesFound if the bucket is empty' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'bucket' }])
      s3_client.stub_responses(:list_objects_v2, name: 'bucket', contents: [])
      instance = described_class.new
      allow(instance).to receive(:send_appsignal_error)
      instance.list_file_names('bucket')
      expect(instance).to have_received(:send_appsignal_error)
        .with(
          action: 'aws-list-file-names',
          exception: described_class::NoFilesFound,
          metadata: { source_bucket: 'bucket' }
        )
    end
  end

  describe '#get_file_contents' do
    it 'returns file contents if the object is not empty' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'bucket' }])
      s3_client.stub_responses(:get_object, body: 'body')
      expect(described_class.new.get_file_contents('bucket', 'file')).to eq('body')
    end

    it 'raises an EmptyContents if the bucket is empty' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'bucket' }])
      s3_client.stub_responses(:get_object, body: '')
      instance = described_class.new
      allow(instance).to receive(:send_appsignal_error)
      instance.get_file_contents('bucket', 'file')
      expect(instance).to have_received(:send_appsignal_error)
        .with(
          action: 'aws-get-file-contents',
          exception: described_class::EmptyContents,
          metadata: {
            source_bucket: 'bucket',
            file_name: 'file'
          }
        )
    end
  end

  describe '#archive_file' do
    it 'is successful if there is no AWS error' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'source_bucket' }, { name: 'archive_bucket' }])
      s3_client.stub_responses(:copy_object)
      s3_client.stub_responses(:delete_object)
      expect(described_class.new.archive_file('source_bucket', 'archive_bucket', 'file')).to be_successful
    end

    it 'sends an appsignal error if AWS throws an error on copy' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'source_bucket' }, { name: 'archive_bucket' }])
      s3_client.stub_responses(:copy_object, 'KeyTooLongError')
      instance = described_class.new
      allow(instance).to receive(:send_appsignal_error)
      instance.archive_file('source_bucket', 'archive_bucket', 'file')
      expect(instance).to have_received(:send_appsignal_error)
        .with(
          action: 'aws-archive-file',
          exception: Aws::S3::Errors::KeyTooLongError,
          namespace: 'tech-support',
          metadata: {
            source_bucket: 'source_bucket',
            archive_bucket: 'archive_bucket',
            file_name: 'file'
          }
        )
    end

    it 'sends an appsignal error if AWS throws an error on delete' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'source_bucket' }, { name: 'archive_bucket' }])
      s3_client.stub_responses(:copy_object)
      s3_client.stub_responses(:delete_object, 'InvalidBucketName')
      instance = described_class.new
      allow(instance).to receive(:send_appsignal_error)
      instance.archive_file('source_bucket', 'archive_bucket', 'file')
      expect(instance).to have_received(:send_appsignal_error)
        .with(
          action: 'aws-archive-file',
          exception: Aws::S3::Errors::InvalidBucketName,
          namespace: 'tech-support',
          metadata: {
            source_bucket: 'source_bucket',
            archive_bucket: 'archive_bucket',
            file_name: 'file'
          }
        )
    end
  end

  describe '#archive_contents' do
    it 'is successful if there is no AWS error' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'archive_bucket' }])
      s3_client.stub_responses(:put_object)
      expect(described_class.new.archive_contents('archive_bucket', 'file', 'text')).to be_successful
    end

    it 'sends an appsignal error if AWS throws an error on copy' do
      s3_client.stub_responses(:list_buckets, buckets: [{ name: 'archive_bucket' }])
      s3_client.stub_responses(:put_object, 'InvalidBucketName')
      instance = described_class.new
      allow(instance).to receive(:send_appsignal_error)
      instance.archive_contents('archive_bucket', 'file', 'text')
      expect(instance).to have_received(:send_appsignal_error)
        .with(
          action: 'aws-archive-contents',
          exception: Aws::S3::Errors::InvalidBucketName,
          namespace: 'tech-support',
          metadata: {
            archive_bucket: 'archive_bucket',
            file_name: 'file'
          }
        )
    end
  end
end
