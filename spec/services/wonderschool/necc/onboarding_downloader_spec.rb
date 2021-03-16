# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe OnboardingDownloader, type: :service do
      let!(:file_name) { 'file_name.csv' }
      let!(:other_file_name) { 'other_file_name.csv' }
      let!(:source_bucket) { 'source_bucket' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:onboarding_data) do
        <<~CSV
          Full Name,Client ID,Provider Name,Date of birth (required),Enrolled in School (Kindergarten or later),Case number,Authorized full day units,Authorized hourly units,Effective on,Expires on,Special Needs Rate?,Special Needs Daily Rate,Special Needs Hourly Rate,Provider Email,Business Zip Code,Business County,Business License,Business QRIS rating,Accredited,Approval #1 - Family Fee,Approval #1 - Begin Date,Approval #1 - End Date,Approval #1 - Allocated Family Fee,Approval #2 - Family Fee,Approval #2 - Begin Date,Approval #2 - End Date,Approval #2 - Allocated Family Fee,Approval #3 - Family Fee,Approval #3 - Begin Date,Approval #3 - End Date,Approval #3 - Allocated Family Fee,Approval #4 - Family Fee,Approval #4 - Begin Date,Approval #4 - End Date,Approval #4 - Allocated Family Fee,Approval #5 - Family Fee,Approval #5 - Begin Date,Approval #5 - End Date,Approval #5 - Allocated Family Fee
          Thomas Eddleman,14047907,Rebecca's Childcare,2010-09-01,No,14635435,276,"1,656",2020-09-01,2021-08-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,0.00,2020-09-01,2021-08-31,0.00,,,,,,,,,,,,,,,,
          Jacob Ford,31610139,Rebecca's Childcare,2017-09-01,No,14635435,276,"1,656",2020-09-01,2021-08-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,0.00,2020-09-01,2021-08-31,0.00,,,,,,,,,,,,,,,,
          Linda Rogers,15228275,Rebecca's Childcare,2019-02-21,No,14635435,276,"1,656",2020-09-01,2021-08-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,0.00,2020-09-01,2021-08-31,0.00,,,,,,,,,,,,,,,,
          Paz Korman,81185504,Rebecca's Childcare,2017-05-17,No,12312445,138,828,2021-01-29,2021-07-31,No,,,rebecca@rebecca.com,68845,Corke,Family Child Care Home II,Step 4,Yes,108.00,2021-01-29,2021-07-31,108.00,,,,,,,,,,,,,,,,
          Becky Falzone,69370816,Kate's Kids,2013-12-26,No,56582912,330,"1,760",2020-11-24,2021-11-23,Yes,90.77,9.43,kate@kate.com,68845,Corke,Family Child Care Home I,Step 5,No,60.00,2020-11-24,2021-05-23,60.00,85.00,2021-05-24,2021-11-23,85.00,,,,,,,,,,,,
        CSV
      end
      let!(:stubbed_client) { double('AWS Client') }
      let!(:stubbed_processor) { double('Wonderschool Necc Onboarding Processor') }
      let!(:stubbed_object) { double('S3 Object') }

      describe '.call' do
        context 'when aws environment variables are set' do
          before(:each) do
            allow(ENV).to receive(:fetch).with('AWS_NECC_ONBOARDING_BUCKET', '').and_return(source_bucket)
            allow(ENV).to receive(:fetch).with('AWS_NECC_ONBOARDING_ARCHIVE_BUCKET', '').and_return(archive_bucket)
            allow(ENV).to receive(:fetch).with('AWS_ACCESS_KEY_ID', '').and_return('fake_key')
            allow(ENV).to receive(:fetch).with('AWS_SECRET_ACCESS_KEY', '').and_return('fake_secret')
            allow(ENV).to receive(:fetch).with('AWS_REGION', '').and_return('fake_region')
            allow(Aws::S3::Client).to receive(:new) { stubbed_client }
            allow(Wonderschool::Necc::OnboardingProcessor).to receive(:new).with(onboarding_data).and_return(stubbed_processor)
          end

          context 'when a single file is present on the S3 bucket' do
            context 'when the file is valid' do
              it 'pulls down the file from S3, runs the job, and archives the file' do
                expect(stubbed_client).to receive(:list_objects_v2).with(
                  { bucket: source_bucket }
                ).and_return({ contents: [{ key: file_name }] })
                expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
                expect(stubbed_object).to receive(:body).and_return(onboarding_data)
                expect(stubbed_processor).to receive(:call).and_return(
                  [
                    [
                      'Full Name', 'Client ID', 'Provider Name', 'Date of birth (required)', 'Enrolled in School (Kindergarten or later)',
                      'Case number', 'Authorized full day units', 'Authorized hourly units', 'Effective on', 'Expires on', 'Special Needs Rate?',
                      'Special Needs Daily Rate', 'Special Needs Hourly Rate', 'Provider Email', 'Business Zip Code', 'Business County',
                      'Business License', 'Business QRIS rating', 'Accredited', 'Approval #1 - Family Fee', 'Approval #1 - Begin Date',
                      'Approval #1 - End Date', 'Approval #1 - Allocated Family Fee', 'Approval #2 - Family Fee', 'Approval #2 - Begin Date',
                      'Approval #2 - End Date', 'Approval #2 - Allocated Family Fee', 'Approval #3 - Family Fee', 'Approval #3 - Begin Date',
                      'Approval #3 - End Date', 'Approval #3 - Allocated Family Fee', 'Approval #4 - Family Fee', 'Approval #4 - Begin Date',
                      'Approval #4 - End Date', 'Approval #4 - Allocated Family Fee', 'Approval #5 - Family Fee', 'Approval #5 - Begin Date',
                      'Approval #5 - End Date', 'Approval #5 - Allocated Family Fee'
                    ],
                    [
                      'Thomas Eddleman', '97017714', "Rebecca's Childcare", '2016-03-22', 'No', '00632405', '276', '1,695', '2020-09-1',
                      '2021-08-31', 'No', nil, nil, 'rebecca@rebecca.com', '68847', 'Buffalo', 'Family Child Care Home II', 'Step 4', 'No',
                      '0.00', '2020-09-1', '2021-08-31', '0.00', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
                    ]
                  ]
                )
                expect(stubbed_client).to receive(:copy_object).with(
                  {
                    bucket: archive_bucket,
                    copy_source: "#{source_bucket}/#{file_name}", key: file_name
                  }
                ).and_return({ copy_object_result: {} })
                expect(stubbed_client).to receive(:delete_object).with({ bucket: source_bucket, key: file_name }).and_return({})
                expect(Rails.logger).to receive(:tagged).and_yield
                expect(Rails.logger).to receive(:info).with(file_name)
                expect(Rails.logger).not_to receive(:error)
                described_class.new.call
              end
            end
            context 'when the file is invalid' do
              it 'logs an error' do
                allow(Wonderschool::Necc::OnboardingProcessor).to receive(:new).with('malformed').and_return(stubbed_processor)
                expect(stubbed_client).to receive(:list_objects_v2).with(
                  { bucket: source_bucket }
                ).and_return({ contents: [{ key: file_name }] })
                expect(stubbed_client).to receive(:get_object).with(
                  { bucket: source_bucket, key: file_name }
                ).and_return(stubbed_object)
                expect(stubbed_object).to receive(:body).and_return('malformed')
                expect(stubbed_processor).to receive(:call).and_return(false)
                expect(stubbed_client).not_to receive(:copy_object)
                expect(stubbed_client).not_to receive(:delete_object)
                expect(Rails.logger).to receive(:tagged).and_yield
                expect(Rails.logger).to receive(:error).with(file_name)
                described_class.new.call
              end
            end
          end

          context 'when there are multiple files in the S3 bucket' do
            context 'when all the files have valid data' do
              it 'logs an info message and does not log an error' do
                expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }, { key: other_file_name }] })
                expect(stubbed_client).to receive(:get_object).twice.and_return(stubbed_object)
                expect(stubbed_object).to receive(:body).twice.and_return(onboarding_data)
                expect(stubbed_processor).to receive(:call).twice.and_return(
                  [
                    [
                      'Full Name', 'Client ID', 'Provider Name', 'Date of birth (required)',
                      'Enrolled in School (Kindergarten or later)', 'Case number', 'Authorized full day units',
                      'Authorized hourly units', 'Effective on', 'Expires on', 'Special Needs Rate?',
                      'Special Needs Daily Rate', 'Special Needs Hourly Rate', 'Provider Email', 'Business Zip Code',
                      'Business County', 'Business License', 'Business QRIS rating', 'Accredited',
                      'Approval #1 - Family Fee', 'Approval #1 - Begin Date', 'Approval #1 - End Date',
                      'Approval #1 - Allocated Family Fee', 'Approval #2 - Family Fee', 'Approval #2 - Begin Date',
                      'Approval #2 - End Date', 'Approval #2 - Allocated Family Fee', 'Approval #3 - Family Fee',
                      'Approval #3 - Begin Date', 'Approval #3 - End Date', 'Approval #3 - Allocated Family Fee',
                      'Approval #4 - Family Fee', 'Approval #4 - Begin Date', 'Approval #4 - End Date',
                      'Approval #4 - Allocated Family Fee', 'Approval #5 - Family Fee', 'Approval #5 - Begin Date',
                      'Approval #5 - End Date', 'Approval #5 - Allocated Family Fee'
                    ],
                    [
                      'Thomas Eddleman', '14047907', "Rebecca's Childcare", '2010-09-01', 'No', '123456789',
                      '276', '1,656', '2020-09-1', '2021-08-31', 'No', nil, nil, 'rebecca@rebecca.com', nil, nil, nil, 'Licensed Center', nil, '0.00',
                      '2020-09-1', '2021-08-31', '0.00', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                      nil, nil, nil, nil, nil, nil
                    ]
                  ]
                )
                expect(stubbed_client).to receive(:copy_object).twice.and_return({ copy_object_result: {} })
                expect(stubbed_client).to receive(:delete_object).twice.and_return({})
                expect(Rails.logger).to receive(:tagged).twice.and_yield
                expect(Rails.logger).to receive(:info).twice
                expect(Rails.logger).not_to receive(:error)
                described_class.new.call
              end
            end
            context 'when one or more of the files has no valid data' do
              it 'logs an info message and logs an error' do
                expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }, { key: other_file_name }] })
                expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
                expect(stubbed_object).to receive(:body).and_return(onboarding_data)
                expect(stubbed_processor).to receive(:call).and_return(
                  [
                    [
                      'Full Name', 'Client ID', 'Provider Name', 'Date of birth (required)',
                      'Enrolled in School (Kindergarten or later)', 'Case number', 'Authorized full day units',
                      'Authorized hourly units', 'Effective on', 'Expires on', 'Special Needs Rate?',
                      'Special Needs Daily Rate', 'Special Needs Hourly Rate', 'Provider Email', 'Business Zip Code',
                      'Business County', 'Business License', 'Business QRIS rating', 'Accredited',
                      'Approval #1 - Family Fee', 'Approval #1 - Begin Date', 'Approval #1 - End Date',
                      'Approval #1 - Allocated Family Fee', 'Approval #2 - Family Fee', 'Approval #2 - Begin Date',
                      'Approval #2 - End Date', 'Approval #2 - Allocated Family Fee', 'Approval #3 - Family Fee',
                      'Approval #3 - Begin Date', 'Approval #3 - End Date', 'Approval #3 - Allocated Family Fee',
                      'Approval #4 - Family Fee', 'Approval #4 - Begin Date', 'Approval #4 - End Date',
                      'Approval #4 - Allocated Family Fee', 'Approval #5 - Family Fee', 'Approval #5 - Begin Date',
                      'Approval #5 - End Date', 'Approval #5 - Allocated Family Fee'
                    ],
                    [
                      'Thomas Eddleman', '14047907', "Rebecca's Childcare", '2010-09-01', 'No', '123456789',
                      '276', '1,656', '2020-09-1', '2021-08-31', 'No', nil, nil, 'rebecca@rebecca.com', nil, nil, nil, 'Licensed Center', nil, '0.00',
                      '2020-09-1', '2021-08-31', '0.00', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                      nil, nil, nil, nil, nil, nil
                    ]
                  ]
                )
                expect(stubbed_client).to receive(:copy_object).with(
                  {
                    bucket: archive_bucket,
                    copy_source: "#{source_bucket}/#{file_name}", key: file_name
                  }
                ).and_return({ copy_object_result: {} })
                expect(stubbed_client).to receive(:delete_object).with(
                  { bucket: source_bucket, key: file_name }
                ).and_return({})
                expect(Rails.logger).to receive(:tagged).and_yield
                expect(Rails.logger).to receive(:info).with(file_name)

                allow(Wonderschool::Necc::OnboardingProcessor).to receive(:new).with('malformed').and_return(stubbed_processor)
                expect(stubbed_client).to receive(:get_object).with(
                  { bucket: source_bucket, key: other_file_name }
                ).and_return(stubbed_object)
                expect(stubbed_object).to receive(:body).and_return('malformed')
                expect(stubbed_processor).to receive(:call).and_return(false)
                expect(stubbed_client).not_to receive(:copy_object)
                expect(stubbed_client).not_to receive(:delete_object)
                expect(Rails.logger).to receive(:tagged).and_yield
                expect(Rails.logger).to receive(:error).with(other_file_name)
                described_class.new.call
              end
            end
          end

          context "when there's no file in the S3 bucket" do
            it 'logs an info message and does not log an error' do
              allow(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [] })
              expect(Rails.logger).to receive(:tagged).and_yield
              expect(Rails.logger).to receive(:info).with("No file found in S3 bucket #{source_bucket} on #{DateTime.now.in_time_zone('Central Time (US & Canada)')}")
              expect(stubbed_client).not_to receive(:get_object)
              expect(stubbed_object).not_to receive(:body)
              expect(stubbed_processor).not_to receive(:call)
              expect(stubbed_client).not_to receive(:copy_object)
              expect(stubbed_client).not_to receive(:delete_object)
              described_class.new.call
            end
          end
        end
      end
    end
  end
end
