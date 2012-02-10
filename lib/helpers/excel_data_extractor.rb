require 'roo'

module ExcelDataExtractor
  EXCEL_HANDLERS = {"xls" => Excel, "xlsx" => Excelx}

  def handle_validation_error(ignored_records_count, record)
    if (record.errors.messages.size > 0)
      ignored_records_count = ignored_records_count + 1
      puts
      $stderr.puts "Record: #{record.inspect}, Error: #{record.errors.messages}"
    end
    ignored_records_count
  end

  def show_summary(records_count, summary_msg)
    if records_count > 0
      puts
      puts records_count.to_s + summary_msg
    end
  end

  def read_from_excel(file_name, sheet_id, &callback)
    ignored_records_count = 0
    exception_records_count = 0
    file = handler(file_name)
    file.default_sheet = file.sheets[sheet_id]
    2.upto(file.last_row) do |line|
      extractor = Proc.new{|column|
        file.cell(line, column)
      }
      record = callback.call(extractor)
      begin
        record.save
        ignored_records_count = handle_validation_error(ignored_records_count, record)
      rescue => e
        exception_records_count = exception_records_count + 1
        puts e
        puts "Error while processing the record: " + record.inspect
      end
    end
    show_summary(ignored_records_count, ' records ignored due to validation errors')
    show_summary(exception_records_count, ' records could not be inserted due to database errors')
  end

  def handler(file_name)
    extension = file_name.split(".").last
    EXCEL_HANDLERS[extension].new(file_name)
  end
end
