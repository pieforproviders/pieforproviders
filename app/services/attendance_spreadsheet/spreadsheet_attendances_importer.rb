# frozen_string_literal: true

require 'rubyXL/convenience_methods/cell'
module AttendanceSpreadsheet
  # Service to fill out center attendance spreadsheet for a given month and year
  # for all the user's approvals.
  class SpreadsheetAttendancesImporter

    def initialize(provider:, month:, year:)
      @provider = User.find(provider)
      @month = month > 9 ? month.to_s : "0#{month}"
      @year = year
    end

    def call
      @provider.approvals.limit(4).each_with_index do |approval,index|

        #Due to RubyXL's limited image handling, workbook needs to be separated into two workbooks
        @workbook_1 = RubyXL::Parser.parse('app/services/attendance_spreadsheet/attendance_month_1.xlsx')
        @worksheet_1 = @workbook_1[0]

        @workbook_2 = RubyXL::Parser.parse('app/services/attendance_spreadsheet/attendance_month_2.xlsx')
        @worksheet_2 = @workbook_2[0]

        #Writes header data to both sheets
        import_user_data

        import_child_data(approval)

        #Temporarily writes to storage folder
        @workbook_1.save("storage/attendances_for_1-15_#{index}.xlsx")
        @workbook_2.save("storage/attendances_for_16-30_#{index}.xlsx")
      end
    end

    private

    def import_child_data(approval)
      child_block_offset = 9
      approval.children.limit(4).each do |child|
        @absence_limit = 5
        import_attendances_per_sheet(child_block_offset, 0, @worksheet_1, child)
        import_attendances_per_sheet(child_block_offset, 1, @worksheet_2, child)

        #Offset needed because spreadsheet has several hidden rows
        child_block_offset += 16
      end
    end

    def import_attendances_per_sheet(child_block_offset, sheet_num, worksheet, child)
      start_date = sheet_num == 1 ? "16" : "01"
      end_date = sheet_num == 1 ? "31" : "15"
      total_info = {
        total_hours_billed: 0,
        total_days_billed: 0,
      }
      worksheet[child_block_offset][1].change_contents("#{child.first_name} #{child.last_name}")
      ("#{@year}-#{@month}-#{start_date}".to_date.."#{@year}-#{@month}-#{end_date}".to_date).each do |date|
        date_col_offset = 0
        total_number_of_hours_per_day = 0
        service_day = child.service_days.find_by(date: date..date.at_end_of_day) 
        next unless service_day
        unless service_day.absence_type == nil
          next unless @absence_limit > 0
          @absence_limit -= 1
          worksheet[child_block_offset + date_col_offset][3 + (date.day - 1).modulo(15)].change_contents('(A)')
        else
          service_day.attendances.where(check_in: date..date.at_end_of_day).limit(2).order(:check_in).each do |attendance|
            #offset by 2 for column
            worksheet[child_block_offset + date_col_offset][3 + (date.day - 1).modulo(15)].change_contents(attendance.check_in.strftime("%I:%M %p"))
            worksheet[child_block_offset + 1 + date_col_offset][3 + (date.day - 1).modulo(15)].change_contents(attendance.check_out.strftime("%I:%M %p"))
            total_number_of_hours_per_day += (attendance.check_out - attendance.check_in) / 3600
            date_col_offset = 2
          end
        end
        # Write total hours for day
        worksheet[child_block_offset + 4][3 + (date.day - 1).modulo(15)].change_contents(total_number_of_hours_per_day.to_i.to_s)
        total_info[:total_hours] += total_number_of_hours_per_day.to_i

        #Write Hour Units Billed
        hour_units = service_day&.tag_hourly&.split(' ')&.first || '0'
        worksheet[child_block_offset + 13][3 + (date.day - 1).modulo(15)].change_contents(hour_units.to_s)
        total_info[:total_hours_billed] += hour_units.to_f

        #Write Daily Units Billed
        daily_units = service_day&.tag_daily&.split(' ')&.first || '0'
        worksheet[child_block_offset + 14][3 + (date.day - 1).modulo(15)].change_contents(daily_units.to_s)
        total_info[:total_days_billed] += daily_units.to_f
      end

      #Write total hours and daily units billed for an entire row
      worksheet[child_block_offset + 1 + sheet_num][18 + sheet_num].change_contents(total_info[:total_hours_billed].round(2).to_s)
      worksheet[child_block_offset + 1 + sheet_num][19 + sheet_num].change_contents(total_info[:total_days_billed].round(2).to_s)
    end

    def import_user_data
      #fill out provider, address, and phone on both sheets
      @worksheet_1[3][3].change_contents(@provider.full_name)
      @worksheet_1[3][17].change_contents(@provider.phone_number)
      @worksheet_1[5][11].change_contents(Time.current.strftime("%m/%d/%Y"))
      @worksheet_1[5][17].change_contents("#{@month.to_s}/#{@year.to_s}")

      @worksheet_2[3][3].change_contents(@provider.full_name)
      @worksheet_2[3][17].change_contents(@provider.phone_number)
      @worksheet_2[5][11].change_contents(Time.current.strftime("%m/%d/%Y"))
      @worksheet_2[5][17].change_contents("#{@month.to_s}/#{@year.to_s}")
    end
  end
end