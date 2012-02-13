require 'roo'
require "import_helper"

module ExcelDataExtractor
  EXCEL_HANDLERS = {"xls" => Excel, "xlsx" => Excelx}

  def handle_validation_error(record)
    unless record.errors.empty?
      $stderr.puts "\nRecord: #{record.inspect}, Error: #{record.errors.messages}"
      return 1
    end
    return 0
  end

  def show_ignored_records_summary(record_count)
    puts 'Came here'
    show_summary record_count, ' ignored due to validation errors'
  end

  def show_exception_records_summary(record_count)
    show_summary record_count, ' could not be inserted due to database errors'
  end

  def show_summary(records_count, summary_msg)
    if records_count > 0
      records_count_msg = ImportHelper::pluralize(records_count, 'record')
      $stderr.puts "\n#{records_count_msg} #{summary_msg}"
    end
  end

  def read_from_excel(file_name, sheet_id, &callback)
    @ignored_records_count = 0
    @exception_records_count = 0
    file = handler(file_name)
    file.default_sheet = file.sheets[sheet_id]
    2.upto(file.last_row) do |line|
      extractor = Proc.new{ |column| file.cell(line, column) }
      record = callback.call(extractor)
      begin
        record.save!
        @ignored_records_count += handle_validation_error(record)
      rescue => e
        @exception_records_count += 1
        $stderr.puts e
        $stderr.puts "Error while processing the record: #{record.inspect}"
      end
    end
    show_ignored_records_summary(@ignored_records_count)
    show_exception_records_summary @exception_records_count
  end

  def handler(file_name)
    extension = file_name.split(".").last
    EXCEL_HANDLERS[extension].new(file_name)
  end
end
