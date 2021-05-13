# frozen_string_literal: true

task create_buckets: :environment do
  BucketCreator.new.call
end
