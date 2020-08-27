# frozen_string_literal: true

require 'open-uri'
require 'csv'
require 'activerecord-import'

# Read in data from zipcode csv files.
# Taken and optimized from the 'my_zipcode_gem' gem rake file.
#
namespace :pie4providers do
  namespace :address_lookups do
    DEFAULT_INPUT_DIR = Rails.root.join('db/lookup_data')
    INPUT_FN_STATES = 'free_zipcode_data_all_us_states.csv'
    INPUT_FN_COUNTIES = 'free_zipcode_data_all_us_counties.csv'
    INPUT_FN_ZIPCODES = 'free_zipcode_data_all_us_zipcodes.csv'

    DEFAULT_EXPORT_DIR = File.join(DEFAULT_INPUT_DIR, 'exports')

    MIN_STATES_EXPECTED = 51
    MIN_COUNTIES_EXPECTED = 3000

    STATES_CSV_COLS = %i[abbr name].freeze
    COUNTIES_CSV_COL_VALUES = %i[name state_id county_seat].freeze
    COUNTIES_CSV_COL_HEADERS = %w[name state county_seat].freeze
    ZIPCODES_CSV_COL_VALUES = %i[code city_id state_id county_id area_code lat lon].freeze
    ZIPCODES_CSV_COL_HEADERS = %w[code city state county area_code lat lon].freeze
    # -----------------------------------------------------------------

    # import_all is about twice as fast
    desc 'Import states.'
    task :import_states, %i[append use_insert_all] => :environment do |_task, args|
      klass = Lookup::State
      klass.delete_all

      args.with_defaults(default_import_args)
      check_for_existing(klass, args)

      start_time = Time.zone.now
      puts_start_import 'states', time: start_time
      default_states_source = File.join(DEFAULT_INPUT_DIR, INPUT_FN_STATES)
      states = csv_rows_from_filenamed default_states_source

      insert_csv_info(klass, STATES_CSV_COLS, states, use_import_all?(args))
      finished_time = Time.zone.now
      puts_interstitial("#{klass.send(:count)} states now in the db.", time: finished_time)
      puts_total_time(start_time, finished_time)
    end

    # import_all time is about the same
    desc 'Import counties (assumes states have been imported'
    task :import_counties, %i[append use_insert_all] => :environment do |_task, args|
      klass = Lookup::County
      klass.delete_all

      args.with_defaults(default_import_args)
      check_for_existing(Lookup::County, args)

      start_time = Time.zone.now
      puts_start_import 'counties, time: start_time'
      state_column = COUNTIES_CSV_COL_VALUES.index(:state_id)

      default_counties_source = File.join(DEFAULT_INPUT_DIR, INPUT_FN_COUNTIES)
      counties = csv_rows_from_filenamed default_counties_source
      counties_with_state_uuids = set_state_uuids(counties, state_column)

      insert_csv_info(klass, COUNTIES_CSV_COL_VALUES, counties_with_state_uuids, use_import_all?(args))
      finished_time = Time.zone.now
      puts_interstitial("#{klass.send(:count)} counties now in the db.", time: finished_time)
      puts_total_time(start_time, finished_time)
      puts_done_msg
    end

    # Ex:
    # code,city,state,county,area_code,lat,lon
    # 00501,Holtsville,NY,SUFFOLK,,40.922326,-72.637078
    # 00544,Holtsville,NY,SUFFOLK,,40.922326,-72.637078
    # 01001,Agawam,MA,HAMPDEN,,42.140549,-72.788661
    #
    # Cities and Counties are imported at the same time because they use the same source file.
    # The source file is large and slow; doing cities and zipcode separately would be slow.
    #
    # insert_all is about the same.
    desc 'Import cities zipcodes (assumes counties and states have been imported)'
    task :import_cities_and_zipcodes, %i[append use_insert_all] => :environment do |_task, args|
      raise "Expected at least #{MIN_STATES_EXPECTED} states. Please be sure the states are populated" if Lookup::State.count < MIN_STATES_EXPECTED
      raise "Expected at least #{MIN_COUNTIES_EXPECTED} counties. Please be sure the counties are populated" if Lookup::County.count < MIN_COUNTIES_EXPECTED

      city_klass = Lookup::City
      city_klass.delete_all
      zips_klass = Lookup::Zipcode
      zips_klass.delete_all

      args.with_defaults(default_import_args)
      use_import_all = use_import_all?(args)
      check_for_existing(Lookup::City, args)
      check_for_existing(Lookup::Zipcode, args)

      state_column = ZIPCODES_CSV_COL_VALUES.index(:state_id)
      county_column = ZIPCODES_CSV_COL_VALUES.index(:county_id)
      city_column = ZIPCODES_CSV_COL_VALUES.index(:city_id)

      start_time = Time.zone.now
      puts_start_import 'cities and zip codes', time: start_time

      default_zips_source = File.join(DEFAULT_INPUT_DIR, INPUT_FN_ZIPCODES)
      puts_interstitial "Reading #{default_zips_source}..."
      rows = csv_rows_from_filenamed default_zips_source

      puts_interstitial 'Setting UUIDs for states and counties...'
      rows_with_all_uuids = set_county_and_state_uuids(rows, state_column, county_column)

      # remove rows duplicated because of multiple zipcodes per city:
      city_rows = rows_with_all_uuids.uniq { |row| row[city_column] + row[state_column] }
      city_rows = city_rows.map { |row| [row[city_column], row[state_column], row[county_column]] }

      create_objects(Lookup::City, %i[name state_id county_id], city_rows, use_import_all)

      set_city_uuids_by_states(rows_with_all_uuids, state_column, city_column)

      create_objects(Lookup::Zipcode, ZIPCODES_CSV_COL_VALUES, rows_with_all_uuids, use_import_all)

      finished_time = Time.zone.now
      puts_done_msg
      puts_total_time(start_time, finished_time)
    end

    desc 'Import states, counties, cities, and zipcodes.'
    task import: :environment do
      Rake::Task['pie4providers:address_lookups:import_states'].invoke
      Rake::Task['pie4providers:address_lookups:import_counties'].invoke
      Rake::Task['pie4providers:address_lookups:import_cities_and_zipcodes'].invoke
    end

    desc 'Import all using import_all (states, counties, cities and zipcodes'
    task import_all: :environment do
      Rake::Task['pie4providers:address_lookups:import_states'].invoke(false, true)
      Rake::Task['pie4providers:address_lookups:import_counties'].invoke(false, true)
      Rake::Task['pie4providers:address_lookups:import_cities_and_zipcodes'].invoke(false, true)
    end

    # Export back into the same format that the free_zipcode_data gem uses
    desc 'Export US States to a .csv file'
    task export_states: :environment do
      csv_string = csv_for_export(Lookup::State.order('name ASC'), STATES_CSV_COLS)
      filename = 'exported_all_us_states'
      exported_fn = write_to(filename, csv_string)
      puts_exported_done('States', exported_fn)
    end

    # Export back into the same format that the free_zipcode_data gem uses
    desc 'Export all US Counties to a .csv file'
    task export_counties: :environment do
      csv_string = CSV.generate do |csv|
        csv << COUNTIES_CSV_COL_HEADERS
        Lookup::County.includes(:state).find_each do |county|
          csv << [
            county.name,
            county.state.abbr,
            county.county_seat
          ]
        end
      end
      filename = 'exported_all_us_counties'
      exported_fn = write_to(filename, csv_string)
      puts_exported_done('Counties', exported_fn)
    end

    # Export back into the same format that the free_zipcode_data gem uses
    desc 'Export the zipcodes with city, county, and state data'
    task export_zipcodes: :environment do
      puts_start_export('Zipcodes and cities')
      csv_string = CSV.generate(headers: true) do |csv|
        csv << ZIPCODES_CSV_COL_HEADERS
        Lookup::Zipcode.includes(:state)
                       .includes(:county)
                       .includes(:city)
                       .find_each do |zip|
          csv << [
            zip.code,
            zip.city.name,
            zip.state.abbr,
            zip.county.name,
            zip.area_code,
            zip.lat,
            zip.lon
          ]
        end
      end
      filename = 'exported_all_us_zipcodes'
      exported_fn = write_to(filename, csv_string)
      puts_exported_done('Zipcodes and city names', exported_fn)
    end

    # Export back into the same format that the free_zipcode_data gem uses
    desc 'Export zipcodes and cities, counties, and states'
    task export: :environment do
      Rake::Task['pie4providers:address_lookups:export_states'].invoke
      Rake::Task['pie4providers:address_lookups:export_counties'].invoke
      Rake::Task['pie4providers:address_lookups:export_zipcodes'].invoke
    end

    # ---------------------------------------------------------------------------

    def check_for_existing(klass, args)
      raise "#{klass} already exist. If you want to import and add more, run this with [true]" unless klass.none? || (args[:append].to_s == true.to_s)
    end

    def default_import_args
      { append: 'false', use_insert_all: false }
    end

    # Read a (text) csv file from the file named filename. Read it all into memory (!)
    #   and return the data as an Array of rows,  without the header rows
    # @return [Array[Array]] - the CSV table without the header rows, as an Array
    def csv_rows_from_filenamed(filename)
      CSV.read(filename, headers: true).to_a.drop(1)
    end

    def set_state_uuids(list, state_column, states = Lookup::State.all)
      change_ref_to_uuid(list, state_column, states, :abbr)
    end

    def set_county_uuids(list, county_column, counties)
      change_ref_to_uuid(list, county_column, counties, :name)
    end

    def set_county_and_state_uuids(rows, state_column, county_column, states = Lookup::State.all)
      # Set the UUIDs for all counties in each state, and set the state UUIDs
      grouped_by_states = rows.group_by { |row| row[state_column] }
      states.each do |state|
        counties = Lookup::County.where(state: state) # all counties in the state
        rows_in_state = grouped_by_states[state.abbr]
        rows_with_county_uuids = set_county_uuids(rows_in_state, county_column, counties)
        rows_with_county_uuids.each { |row| row[state_column] = state.id }
        # Lookup::County.upsert_all()
      end
      grouped_by_states.values.flatten(1)
    end

    def set_city_uuids_by_states(list, state_column, city_column, states = Lookup::State.all)
      grouped_by_states = list.group_by { |row| row[state_column] }
      states.each do |state|
        rows_in_state = grouped_by_states[state.id]
        cities = Lookup::City.where(state: state)
        set_city_uuids(rows_in_state, city_column, cities)
      end
    end

    def set_city_uuids(list, city_column, cities)
      change_ref_to_uuid(list, city_column, cities, :name)
    end

    # Change a reference to something to a UUID.
    # Given a list of things with a reference (e.g. a name of a city) [list_with_refs],
    #  and given a list of those references (cities) with their UUIDs [uuid_objs],
    #  change all of the references (names) in the list of things to the uuids.
    #  Use the method 'ref_value_method' to get the reference value (e.g. :name)
    #  from the object with the UUID.
    #
    # @param [Array] list_with_refs - the list of things that have references
    #   that we need to replace with UUIDs
    # @param [Integer] col_to_change - the index of the column [Array item] that needs to be
    #   changed from a reference to a UUID
    # @param [Enumerable] uuid_objs - list of objects that have UUIDs and that also
    #   also respond to the ref_value_method (e.g. to get the value of an attribute)
    # @param [Symbol] ref_value_method - method to send to an object with UUID to get
    #   the value for the reference (e.g. the :name of the object)
    #
    # @return [Array] - the list of things with UUIDs replacing the references
    #   at [col_to_change]
    def change_ref_to_uuid(list_with_refs, col_to_change, uuid_objs, ref_value_method)
      grouped_by_refs = list_with_refs.group_by { |item| item[col_to_change] }
      # set the uuid reference for all of the items with that reference value in [col_to_change]:
      uuid_objs.each do |obj_with_uuid|
        grouped_by_refs.fetch(obj_with_uuid.send(ref_value_method), []).each { |item| item[col_to_change] = obj_with_uuid.id }
      end
      grouped_by_refs.values.flatten(1)
    end

    def create_objects(klass, col_headers = [], rows = [], use_import_all = false)
      start_time = Time.zone.now
      puts_interstitial "Creating #{klass}..."
      insert_csv_info(klass, col_headers, rows, use_import_all)
      finished_time = Time.zone.now
      puts_interstitial "   #{klass.send(:count)} now in the db.", time: finished_time
      puts_interstitial '  done.'
      puts_total_time(start_time, finished_time, msg: "  Total time for #{klass}")
    end

    def insert_csv_info(klass, col_headers, rows, use_insert_all = false)
      if use_insert_all
        insert_all_from_csv(klass, col_headers, rows)
      else
        klass.send(:import, col_headers, rows, validate: true)
      end
    end

    def use_import_all?(args)
      args.fetch(:use_insert_all, false).to_s == true.to_s
    end

    def insert_all_from_csv(klass, col_headers = [], rows = [])
      return [] if rows.empty?

      verify_headers_and_cols_for_insert(col_headers, rows)

      timestamp = Time.zone.now
      items_to_insert = rows.map do |row|
        new_item = {}
        col_headers.each_with_index do |col_header, i|
          new_item[col_header.to_sym] = row[i]
          new_item[:created_at] = timestamp
          new_item[:updated_at] = timestamp
        end
        new_item
      end

      klass.send(:insert_all!, items_to_insert)
    end

    def verify_headers_and_cols_for_insert(col_headers = [], rows = [])
      raise 'No column headers. Nothing done' if col_headers.empty?

      # rubocop complains if I make this 1 long guard clause
      # rubocop:disable Style/GuardClause
      unless col_headers.size == rows.first.size
        raise "Number of headers columns does not match number of columns in the first row:\n" \
              "  column headers: #{col_headers.inspect}\n" \
              "  first row: #{rows.first.inspect}"
      end
      # rubocop:enable Style/GuardClause
    end

    # @return [String] - full filename that was written to
    def write_to(filename, data, fn_ext = 'csv')
      mkdir_p(DEFAULT_EXPORT_DIR) unless Dir.exist? DEFAULT_EXPORT_DIR
      export_fn = File.join(DEFAULT_EXPORT_DIR, "#{filename}-#{Time.zone.now.strftime('%F-%H%M%S%L')}.#{fn_ext}")
      File.open(export_fn, 'w') { |f| f.write(data) }
      export_fn
    end

    def csv_for_export(list, attributes)
      CSV.generate(headers: true) do |csv|
        csv << attributes
        list.each do |item|
          csv << attributes.map { |attr| item.send(attr) }
        end
      end
    end

    def puts_interstitial(msg, time: Time.zone.now)
      puts "   #{msg} #{formatted(time)}"
    end

    def puts_start_import(component_name, time: Time.zone.now)
      puts "Importing #{component_name}... (started at: #{formatted(time)} )"
    end

    def puts_start_export(component_name, time: Time.zone.now)
      puts "Exporting #{component_name}... (started at: #{formatted(time)} )"
    end

    def puts_exported_done(name, filename, time: Time.zone.now)
      puts_done_msg("#{name} exported to #{filename} ( at: #{formatted(time)} )")
    end

    def puts_done_msg(msg = '', time: Time.zone.now)
      puts "...done. (finished at: #{formatted(time)} )"
      puts msg if msg.present?
    end

    def puts_total_time(start_time, end_time, msg: 'Total time')
      puts format('  %<msg>s: %<total_time>2.6f', msg: msg, total_time: (end_time.to_f - start_time.to_f))
    end

    def formatted(time = Time.zone.now)
      time.iso8601(9)
    end
  end
end
