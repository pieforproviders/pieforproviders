# frozen_string_literal: true

module Commands
  module Attendance
    # Parses PDFs using options defined in the private methods
    # rubocop:disable Metrics/ClassLength
    class ParsePdf
      include AppsignalReporting
      attr_reader :attendances

      def initialize(content)
        @file = ''
        @content = content
        @attendances = []
        @dates_index = 0
      end

      def call
        temp_file = Tempfile.new(['temp_pdf', '.pdf'])
        temp_file.write(@content)
        temp_file.close
        @file = temp_file
        attendances_information
      end

      def child
        find_child_name
      end

      def business
        find_business_name
      end

      private

      # rubocop: disable Metrics/AbcSize Metrics/MethodLength
      # rubocop: disable Metrics/MethodLength
      def find_child_name
        File.open(@file, 'rb') do |io|
          reader = PDF::Reader.new(io)
          first_page = reader.pages.first
          splitted_page = split_page_by_break_line(first_page)
          reduced_splited_page = remove_unnecessary_spaces(splitted_page)
          names = reduced_splited_page.second.split('for').last.split(',')
          first_name = names.last.split.first
          last_name = names.first.gsub('-', ' ').strip
          [last_name, first_name]
        rescue StandardError => e
          # rubocop:disable Rails/Output
          pp "Error finding child, please check if the child's name contains any special character or extra names.
           error => #{e.inspect}"
          # rubocop:enable Rails/Output
        end
      end
      # rubocop: enable Metrics/AbcSize Metrics/MethodLength
      # rubocop: enable Metrics/MethodLength

      def find_business_name
        File.open(@file, 'rb') do |io|
          reader = PDF::Reader.new(io)
          first_page = reader.pages.first
          splitted_page = split_page_by_break_line(first_page)
          reduced_splited_page = remove_unnecessary_spaces(splitted_page)
          reduced_splited_page[2]
        end
      end

      def attendances_information
        File.open(@file, 'rb') do |io|
          reader = PDF::Reader.new(io)
          reader.pages.each do |page|
            check_pages_size(page)
            process_page(page)
          end
        end
        @attendances
      rescue StandardError => e
        send_appsignal_error(
          action: 'csv-parser',
          exception: e
        )
      end

      def check_pages_size(page)
        required_size = [0, 0, 2383.9199, 1684.08]
        pages_size = page.attributes[:MediaBox]

        raise "Error on file #{@file}. error => wrong format" if pages_size.sort != required_size.sort
      rescue StandardError => e
        # rubocop:disable Rails/Output
        pp "PDF reader stoped. error => #{e.message}"
        # rubocop:enable Rails/Output
      end

      def process_page(page)
        page_splitted_by_break_line = split_page_by_break_line(page)
        regex = /(\d{1,2}\s[A-Za-z]+\,\s\d{4})(?:.*?(\d{1,2}:\d{2}\s?[AP]M))?(?:.*?(\d{1,2}:\d{2}\s?[AP]M))?/ # rubocop:disable Style/RedundantRegexpEscape
        raw_attendances = build_raw_attendances(page_splitted_by_break_line)
        attendances_info = raw_attendances.map { |attendance| attendance.scan(regex).flatten }
        build_attendances(attendances_info)
      end

      # rubocop:disable Layout/LineLength
      def build_check_in_out(dates)
        dates.each do |date|
          is_empty = @attendances[@dates_index][:sign_out_time].blank?
          @attendances[@dates_index][:sign_in_time] = "#{date} " + @attendances[@dates_index][:sign_in_time]
          @attendances[@dates_index][:sign_out_time] = is_empty ? nil : "#{date} " + @attendances[@dates_index][:sign_out_time]
          @dates_index += 1
        end
      end
      # rubocop:enable Layout/LineLength

      def remove_unnecessary_spaces(splitted_page)
        splitted_page.map { |s| s.squeeze(' ').strip }
      end

      def split_page_by_break_line(page)
        page.text.split("\n").reject(&:empty?)
      end

      def time_pattern
        /\d{1,2}:\d{2}(?:\s?[ap]m)?/i
      end

      def build_raw_attendances(page_splitted_by_break_line)
        break_index = find_break_index(page_splitted_by_break_line) + 1
        attendances_without_first_lines = page_splitted_by_break_line[break_index..]
        attendances_without_first_lines.pop
        attendances_without_first_lines
      end

      def find_break_index(splitted_text)
        splitted_text.each_with_index.find { |s, _| s.include? 'Total hours' }.pop
      end

      def build_text_without_tabs(raw_attendances)
        raw_attendances.join.gsub(/\s+/, ' ')
      end

      def build_times(text_without_tabs)
        hours_without_am_pm = text_without_tabs.scan(time_pattern)
        complete_times = []
        hours_without_am_pm.each do |time|
          complete_times << time.to_s
        end
        complete_times
      end

      def build_dates(raw_attendances)
        dates = []

        raw_attendances.each do |line|
          date = find_and_build_date(line)
          next if date.blank?

          dates << date
        end

        dates
      end

      def raw_line(text)
        text.strip.split(/\s+/)
      end

      def find_and_build_date(line)
        date = line.match(/\b\d{1,2}\s*[A-Za-z]+,\s*\d{4}\b/)
        date[0]
      end

      def build_attendances(attendances_info)
        attendances_info.each do |attendance|
          date = attendance.first
          check_in = attendance.second
          check_out = attendance.last
          sign_in_time = check_in.present? ? "#{date} #{check_in}" : nil
          sign_out_time = check_out.present? ? "#{date} #{check_out}" : nil
          @attendances << {
            sign_in_time:,
            sign_out_time:
          }
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
