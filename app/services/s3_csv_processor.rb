class S3CsvProcessor < S3Client
  def call
    download_process_and_archive
  end

  protected

  def csv_parsing_config
    raise 'not implemented'
  end

  def process
    raise 'not implemented'
  end

  def source_bucket
    raise 'not implemented'
  end

  def archive_bucket
    raise 'not implemented'
  end

  def download_process_and_archive
    file_names = list_objects(source_bucket)
    file_names.each do |file_name|
      records = parse_contents(get_object(source_bucket, file_name).body)
      process(records)
      archive_file(file_name, source_bucket, archive_bucket)
    end
  end

  def parse_contents(contents)
    log(:error, 'blank contents') and return false if contents.blank?

    CSV.parse(contents, csv_parsing_config)
  end
end
