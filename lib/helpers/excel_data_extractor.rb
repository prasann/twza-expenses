# TODO: Is this even used anywhere in this project?
require 'roo'
require 'iconv'

module ExcelDataExtractor
  EXCEL_HANDLERS = {"xls" => Excel, "xlsx" => Excelx}

  def read_from_excel(file_name, sheet_id, &callback)
    ignored_records_count = 0
    file = handler(file_name)
    file.default_sheet = file.sheets[sheet_id]
    at_least_one_successful_record = false
    2.upto(file.last_row) do |line|
      extractor = Proc.new{ |column| file.cell(line, column) }
      record = callback.call(extractor)
      if record.save
        at_least_one_successful_record = true
      else
        $stderr.puts "Record: #{record.inspect}, Errors: #{record.errors.full_messages.join(',')}"
        ignored_records_count += 1
      end
    end
    $stderr.puts "\n"
    show_summary(ignored_records_count, "(out of a total count of #{file.last_row - 1}) ignored due to the above errors")
    at_least_one_successful_record
  end

  private
  def show_summary(records_count, summary_msg)
    if records_count > 0
      records_count_msg = ImportHelper::pluralize(records_count, 'record')
      $stderr.puts "#{records_count_msg} #{summary_msg}"
    end
  end

  def handler(file_name)
    extension = file_name.split(".").last
    EXCEL_HANDLERS[extension].new(file_name)
  end
end
