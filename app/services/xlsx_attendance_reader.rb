require 'roo'

# Reads attendance info from an .xlsx file
class XlsxAttendanceReader
  attr_reader :content, :children_data

  def initialize(content)
    @content = content
    @children_data = []

  end

  def process
    temp_file = Tempfile.new(['temp_xlsx', '.xlsx'])
    temp_file.write(content)
    temp_file.close

    workbook = Roo::Spreadsheet.open(temp_file.path)
    @worksheet = workbook.sheet(0)

    process_row(@worksheet)

    @children_data
  ensure
    temp_file&.unlink
  end

  private

  def process_row(worksheet)
    (8..worksheet.last_row).each do |row|
      first_name = worksheet.cell(row, 1).strip
      last_name = worksheet.cell(row, 2).strip
      check_in_out_data = extract_check_in_out_data(worksheet, row)

      @children_data << {
        first_name: first_name,
        last_name: last_name,
        check_in_out_data: check_in_out_data
      }
    end
  end

  def extract_year(text)
    year_pattern = /\d{4}/
    text.scan(year_pattern).drop(1).join
  end

  def extract_check_in_out_data(worksheet, row)
    @check_in_out_data = []
    dates = (6..worksheet.last_column).step(2).map { |col| worksheet.cell(6, col - 1) }.drop(1)

    (7..worksheet.last_column).step(2).each_with_index do |col, index|
      check_in = worksheet.cell(row, col)
      check_out = worksheet.cell(row, col + 1)

      next unless check_in && check_out

      build_data(check_in, check_out, dates, index)
    end

    @check_in_out_data
  end

  def format_datetime(input_string)
    datetime = DateTime.strptime(input_string, '%b %d, %Y %I:%M %p')
    datetime.strftime('%Y-%m-%d %I:%M %p')
  end

  def build_data(check_in, check_out, dates, index)
    time_pattern = /(\d{1,2}:\d{2} (?:AM|PM))/i

    first_row = @worksheet.row(1).compact!.join
    year = extract_year(first_row)

   if check_in.empty? || check_out.empty?
     @check_in_out_data << { check_in: '', check_out: '' }
   else
     datetime_check_in = dates[index] + ", #{year} " + check_in.scan(time_pattern).flatten.join.to_s
     datetime_check_out = dates[index] + ", #{year} " + check_out.scan(time_pattern).flatten.join.to_s

     formated_check_in = format_datetime(datetime_check_in)
     formated_check_out = format_datetime(datetime_check_out)

     @check_in_out_data << {
       check_in: formated_check_in,
       check_out: formated_check_out
     }
   end
  end
end
