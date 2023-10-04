# frozen_string_literal: true

# lib/tasks/update_children.rake

require 'csv'
require 'aws-sdk-s3'

namespace :children do
  desc "Update children's wonderschool_id from a CSV file in an AWS S3 bucket"
  task update_wonderschool_id: :environment do
    @client = AwsClient.new
    @source_bucket = Rails.application.config.aws_necc_attendance_bucket
    @archive_bucket = Rails.application.config.aws_necc_attendance_archive_bucket

    file = @client.list_file_names(@source_bucket).select { |f| f.end_with? 'children_dhs_id_update.csv' }.first
    csv_content = @client.get_file_contents(@source_bucket, file)

    CSV.parse(csv_content, headers: true) do |row|
      child = Child.find_by(id: row['child_id'])
      if child && row['update_id'] != 'null'
        child.update(wonderschool_id: row['update_id'])
        puts "Updated Child #{child.id} with dhs_id #{child.wonderschool_id}"
      elsif child && row['update_id'] == 'null'
        puts "Skipped Child #{child.id} due to 'null' update_id"
      else
        puts "Child with id #{row['child_id']} not found"
      end
    end
  end
end
