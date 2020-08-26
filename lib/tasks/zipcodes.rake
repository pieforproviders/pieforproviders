# frozen_string_literal: true

require 'open-uri'
require 'csv'
require 'activerecord-import'

# Read in data from zipcode csv files.
# Taken and cleaned up a bit from my_zipcode_gem gem.
#
namespace :zipcodes_gem do
  DEFAULT_DATA_SOURCE_URL = 'https://github.com/midwire/free_zipcode_data/raw/master/'

  STATES_CSV_COLS = %i[abbr name].freeze
  COUNTIES_CSV_COLS = %i[name state_id county_seat].freeze
  ZIPCODES_CSV_COLS = %i[code city state_id county_id area_code lat lon].freeze

  # -----------------------------------------------------------------

  desc 'Import states'
  task import_states: :environment do
    puts_start_import 'states'
    default_states_source = File.join(DEFAULT_DATA_SOURCE_URL, 'all_us_states.csv')

    state_rows = csv_rows_from_url default_states_source

    # remove the first row, which is a header
    Lookups::State.import STATES_CSV_COLS, state_rows.to_a.drop(1), validate: true
    puts_done_msg
  end

  desc 'Import counties (assumes states have been imported'
  task import_counties: :environment do
    puts_start_import 'counties'
    state_column = COUNTIES_CSV_COLS.index('state_id')

    default_counties_source = File.join(DEFAULT_DATA_SOURCE_URL, 'all_us_counties.csv')
    county_rows = csv_rows_from_url default_counties_source

    counties = county_rows.to_a.drop(1) # drop the header row
    counties_with_state_uuids = set_state_uuids(counties, state_column)

    Lookups::County.import COUNTIES_CSV_COLS, counties_with_state_uuids, validate: true
    puts_done_msg
  end


  desc 'Import zipcodes (assumes counties and states have been imported)'
  task import_zipcodes: :environment do
    puts_start_import 'zip codes'
    default_zips_source = File.join(DEFAULT_DATA_SOURCE_URL, 'all_us_zipcodes.csv')
    zip_rows = csv_rows_from_url default_zips_source

    state_column = ZIPCODES_CSV_COLS.index('state_id')
    county_column = ZIPCODES_CSV_COLS.index('county_id')

    zips = zip_rows.to_a.drop(1)
    # A county name is only unique within 1 state. (many states might have the same county name)
    grouped_by_states = zips.group_by { |zip| zip[state_column] }
    Lookups::State.all.each do |state|
      counties = Lookups::County.where(state: state) # all counties in the state
      zips_in_state = grouped_by_states[state.abbr]
      set_county_uuids(zips_in_state, county_column, counties)
      zips_in_state.each { |zip| zip[state_column] = state.id }
    end
    zips_with_all_uuids = grouped_by_states.values.flatten(1)

    Lookups::Zipcode.import ZIPCODES_CSV_COLS, zips_with_all_uuids, validate: true
    puts_done_msg
  end

  desc 'Import states, counties, and zipcodes.'
  task import: :environment do
    Rake::Task['zipcodes_gem:import_states'].invoke
    Rake::Task['zipcodes_gem:import_counties'].invoke
    Rake::Task['zipcodes_gem:import_zipcodes'].invoke
  end

  desc 'Export US States to a .csv file'
  task export_states: :environment do
    @states = Lookups::State.order('name ASC')
    csv_string = CSV.generate do |csv|
      csv << %w[abbr name]
      @states.each do |state|
        csv << [
          state.abbr,
          state.name
        ]
      end
    end
    filename = 'all_us_states.csv'
    File.open("#{Rails.root}/db/#{filename}", 'w') do |f|
      f.write(csv_string)
    end
    puts_done_msg
  end

  desc 'Export all US Counties to a .csv file'
  task export_counties: :environment do
    @counties = Lookups::County.order('name ASC')
    csv_string = CSV.generate do |csv|
      csv << %w[name state county_seat]
      @counties.each do |county|
        csv << [
          county.name,
          county.state.abbr,
          county.county_seat
        ]
      end
    end
    filename = 'all_us_counties.csv'
    File.open("#{Rails.root}/db/#{filename}", 'w') do |f|
      f.write(csv_string)
    end
    puts_done_msg
  end

  desc 'Export the zipcodes with county and state data'
  task export_zipcodes: :environment do
    @zipcodes = Lookups::Zipcode.order('code ASC')
    csv_string = CSV.generate do |csv|
      csv << %w[code city state county area_code lat lon]
      @zipcodes.each do |zip|
        csv << [
          zip.code,
          zip.city,
          zip.state.abbr,
          zip.county.nil? ? '' : zip.county.name,
          zip.area_code,
          zip.lat,
          zip.lon
        ]
      end
    end
    filename = 'all_us_zipcodes.csv'
    File.open("#{Rails.root}/db/#{filename}", 'w') do |f|
      f.write(csv_string)
    end
    puts_done_msg
  end

  desc 'Export zipcodes, states and counties tables'
  task export: :environment do
    Rake::Task['zipcodes_gem:export_states'].invoke
    Rake::Task['zipcodes_gem:export_counties'].invoke
    Rake::Task['zipcodes_gem:export_zipcodes'].invoke
  end

  # ---------------------------------------------------------------------------

  # Read a (text) csv file from the url. Read it all into memory (!)
  #   and return the data as an Array of rows,  without the header rows
  # @return [Array[Array]] - the CSV table without the header rows, as an Array
  def csv_rows_from_url(url)
    csv_table_from(url).to_a.drop(1)
  end

  # @return [String] - absolute path and filename of the local file with the url data
  def csv_table_from(uri)
    local_tempfile = nil
    OpenURI.open_uri(uri) do
      if data.is_a? StringIO
        local_tempfile = Tempfile.new('temp.csv')
        local_tempfile.write(data.read)
        local_tempfile.flush
        local_tempfile.close
      end
    end
    raise IOError, "Could not read data from #{url}" if local_tempfile.nil?

    csv_table = CSV.read(local_tempfile.path, headers: true)
    local_tempfile.unlink
    csv_table
  end

  def read_csv_from_file(full_filename)
    csv_table = CSV.read(full_filename, headers: true)
    csv_table.to_a.drop(1)
  end

  def set_state_uuids(list, state_column, states = Lookups::State.all)
    change_ref_to_uuid(list, state_column, states, :abbr)
  end

  def set_county_uuids(list, county_column, counties)
    change_ref_to_uuid(list, county_column, counties, :name)
  end

  def change_ref_to_uuid(list_with_refs, col_to_change, uuid_objs, ref_value_method)
    grouped_by_refs = list_with_refs.group_by { |item| item[col_to_change] }
    # set the uuid reference for all of the items with that state in the state_column:
    uuid_objs.each do |obj_with_uuid|
      grouped_by_refs.fetch(obj_with_uuid.send(ref_value_method), []).each { |item| item[col_to_change] = obj_with_uuid.id }
    end
    grouped_by_refs.values.flatten(1)
  end

  def puts_start_import(component_name)
    puts "Importing #{component_name}..."
  end

  def puts_start_export(component_name)
    puts "Exporting #{component_name} to #{destination}..."
  end

  def puts_done_msg
    puts '   ...done.'
  end
end
