# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe DashboardDownloader, type: :service do
      let!(:file_name) { 'file_name.csv' }
      let!(:other_file_name) { 'other_file_name.csv' }
      let!(:source_bucket) { 'source_bucket' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:dashboard_data) do
        <<~CSV
          As of Date,Child Name,Case Number,Business,Full Days,Hourly,Absences,Status,Earned revenue,Estimated Revenue,Approved (Scheduled) revenue,Transportation revenue
          2021-02-21,Sarah Brighton,23434235,Test Day Care,0 of 20,0 of 0,"0 days, 0 hours",at_risk,0,90.77,"1,815.40",n/a
          2021-02-25,Charles Williamson,23434235,Test Day Care,1 of 15,1 of 18,"1 day, 0 hours",on_track,98.21,1234.56,"1,815.40",2 trips - $22.00
          2021-02-24,Marcus Wright,23434235,Test Day Care,3 of 15,4 of 18,"0 days, 4 hours",exceeded_limit,330.00,330.00,"1,815.40",n/a
        CSV
      end
      let!(:stubbed_client) { double('AWS Client') }
      let!(:stubbed_processor) { double('Wonderschool Necc Dashboard Processor') }
      let!(:stubbed_object) { double('S3 Object') }

      describe '.call' do
        context 'when aws environment variables are set' do
          before(:each) do
            allow(ENV).to receive(:fetch).with('AWS_NECC_DASHBOARD_BUCKET', '').and_return(source_bucket)
            allow(ENV).to receive(:fetch).with('AWS_NECC_DASHBOARD_ARCHIVE_BUCKET', '').and_return(archive_bucket)
            allow(ENV).to receive(:fetch).with('AWS_ACCESS_KEY_ID', '').and_return('fake_key')
            allow(ENV).to receive(:fetch).with('AWS_SECRET_ACCESS_KEY', '').and_return('fake_secret')
            allow(ENV).to receive(:fetch).with('AWS_REGION', '').and_return('fake_region')
            allow(Aws::S3::Client).to receive(:new) { stubbed_client }
            allow(Wonderschool::Necc::DashboardProcessor).to receive(:new).with(dashboard_data).and_return(stubbed_processor)
          end

          context 'when a single file is present on the S3 bucket' do
            context 'when the file is valid' do
              it 'pulls down the file from S3, runs the job, and archives the file' do
                expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
                expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
                expect(stubbed_object).to receive(:body).and_return(dashboard_data)
                expect(stubbed_processor).to receive(:call).and_return([%w[child_id checked_in_at checked_out_at],
                                                                        ['123456789', 'Sat, 06 Feb 2021 07:59:49AM', 'Sat, 06 Feb 2021 12:12:03PM']])
                expect(stubbed_client).to receive(:copy_object).with({
                                                                       bucket: archive_bucket,
                                                                       copy_source: "#{source_bucket}/#{file_name}", key: file_name
                                                                     }).and_return({ copy_object_result: {} })
                expect(stubbed_client).to receive(:delete_object).with({ bucket: source_bucket, key: file_name }).and_return({})
                expect(Rails.logger).to receive(:tagged).and_yield
                expect(Rails.logger).to receive(:info).with(file_name)
                expect(Rails.logger).not_to receive(:error)
                described_class.new.call
              end
            end
            context 'when the file is invalid' do
              it 'logs an error' do
                allow(Wonderschool::Necc::DashboardProcessor).to receive(:new).with('malformed').and_return(stubbed_processor)
                expect(stubbed_client).to receive(:list_objects_v2).with({ bucket: source_bucket }).and_return({ contents: [{ key: file_name }] })
                expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: file_name }).and_return(stubbed_object)
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
                expect(stubbed_object).to receive(:body).twice.and_return(dashboard_data)
                expect(stubbed_processor).to receive(:call).twice.and_return(
                  [%w[child_id checked_in_at checked_out_at],
                   ['123456789', 'Sat, 06 Feb 2021 07:59:49AM', 'Sat, 06 Feb 2021 12:12:03PM']]
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
                expect(stubbed_object).to receive(:body).and_return(dashboard_data)
                expect(stubbed_processor).to receive(:call).and_return([%w[child_id checked_in_at checked_out_at],
                                                                        ['123456789', 'Sat, 06 Feb 2021 07:59:49AM', 'Sat, 06 Feb 2021 12:12:03PM']])
                expect(stubbed_client).to receive(:copy_object).with({
                                                                       bucket: archive_bucket,
                                                                       copy_source: "#{source_bucket}/#{file_name}", key: file_name
                                                                     }).and_return({ copy_object_result: {} })
                expect(stubbed_client).to receive(:delete_object).with({ bucket: source_bucket, key: file_name }).and_return({})
                expect(Rails.logger).to receive(:tagged).and_yield
                expect(Rails.logger).to receive(:info).with(file_name)

                allow(Wonderschool::Necc::DashboardProcessor).to receive(:new).with('malformed').and_return(stubbed_processor)
                expect(stubbed_client).to receive(:get_object).with({ bucket: source_bucket, key: other_file_name }).and_return(stubbed_object)
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
              expect(Rails.logger).to receive(:info).with("No file found in S3 bucket #{source_bucket} at #{Time.current.strftime('%m/%d/%Y %I:%M%p')}")
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
