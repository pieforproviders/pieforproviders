# frozen_string_literal: true

module Commands
  module Attendance
    # Parses PDFs using options defined in the private methods
    class ParsePdf
      include AppsignalReporting
      attr_reader :attendances

      def initialize(file: '', child: nil)
        @file = file
        @attendances = []
        @child = child
      end

      def call
        attendances_information
      end

      private

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
        raise "Error on file #{@file}. error => wrong format" if pages_size != required_size
      rescue StandardError => e
        # rubocop:disable Rails/Output
        pp "PDF reader stoped. error => #{e.message}"
        # rubocop:enable Rails/Output
      end

      def process_page(page)
        page_splitted_by_break_line = split_page_by_break_line(page)
        reduced_splited_page = remove_unnecessary_spaces(page_splitted_by_break_line)
        raw_attendances = build_raw_attendances(reduced_splited_page)
        text_without_tabs = build_text_without_tabs(raw_attendances)
        complete_times = build_times(text_without_tabs)

        dates = build_dates(raw_attendances)
        build_attendances(complete_times)

        dates.each do |date|
          @attendances[start_dates_index][:date] = date
        end
      end

      def start_dates_index
        0 if @attendances.empty?
        first_element_without_date = @attendances.find { |item| !item.key?(:date) }
        @attendances.index(first_element_without_date)
      end

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

          dates << date.to_date
        end

        dates
      end

      def raw_line(text)
        text.strip.split(/\s+/)
      end

      def find_and_build_date(line)
        date = line.match(/\b\d{1,2}\s*[A-Za-z]+,\s*\d{4}\b/)
        Date.strptime(date[0], '%d %B, %Y')
      end

      def build_attendances(complete_times)
        complete_times.each_slice(2) do |sign_in_time, sign_out_time|
          @attendances << {
            sign_in_time: sign_in_time,
            sign_out_time: sign_out_time
          }
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
