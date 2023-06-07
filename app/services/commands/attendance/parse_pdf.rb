# frozen_string_literal: true

module Commands
  module Attendance
    # Parses PDFs using options defined in the private methods
    # rubocop:disable Metrics/ClassLength
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
            process_page(page)
          end
        end
      rescue StandardError => e
        send_appsignal_error(
          action: 'csv-parser',
          exception: e
        )
      end

      def process_page(page)
        page_splitted_by_break_line = split_page_by_break_line(page)
        raw_attendances = build_raw_attendances(page_splitted_by_break_line)
        text_without_tabs = build_text_without_tabs(raw_attendances)
        complete_times = build_times(text_without_tabs)

        dates = build_dates(raw_attendances)
        build_attendances(complete_times)

        dates.each.with_index do |date, index|
          @attendances[index][:date] = date
        end
      end

      def split_page_by_break_line(page)
        page.text.split("\n").reject(&:empty?)
      end

      def time_pattern
        /\d{1,2}:\d{2}(?:\s?[ap]m)?/i
      end

      def build_raw_attendances(page_splitted_by_break_line)
        attendances_without_firs_nine_lines = page_splitted_by_break_line[9..]
        attendances_without_firs_nine_lines.pop
        attendances_without_firs_nine_lines
      end

      def build_text_without_tabs(raw_attendances)
        raw_attendances.join.gsub(/\s+/, ' ')
      end

      def build_times(text_without_tabs)
        hours_without_am_pm = text_without_tabs.scan(time_pattern)
        ams_pms = text_without_tabs.scan(Regexp.union(/PM/, /AM/))
        complete_times = []
        hours_without_am_pm.each_with_index do |time, index|
          complete_times << "#{time} #{ams_pms[index]}"
        end
        complete_times
      end

      def build_dates(raw_attendances)
        dates = []
        date_fields_to_nil

        raw_attendances.each do |line|
          date = build_date(line)
          next if date.blank?

          date_fields_to_nil
          dates << date.to_date
        end

        dates
      end

      def raw_line(text)
        text.strip.split(/\s+/)
      end

      def build_date(text)
        full_date = ''
        raw_line(text).each do |part|
          assign_date_fields(part)

          next if @day.nil? || @month.nil? || @year.nil?

          full_date = "#{@day}, #{@month}, #{@year}"
        end

        full_date
      end

      def date_fields_to_nil
        @day = nil
        @month = nil
        @year = nil
      end

      def assign_date_fields(text)
        build_day(text) if @day.nil?
        build_month(text) if @month.nil?
        build_year(text) if @year.nil?
      end

      def build_day(text)
        @day = text if text.match(/^\d{1,2}$/).present?
      end

      def build_month(text)
        @month = text.chomp(',') if text.match(/^[A-Za-z]+,$/).present?
      end

      def build_year(text)
        @year = text if text.match(/^\d{4}$/).present?
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
