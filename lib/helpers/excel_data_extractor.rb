require 'roo'
require 'iconv'

module ExcelDataExtractor
  include ActionView::Helpers::TextHelper

  EXCEL_HANDLERS = {"xls" => Excel, "xlsx" => Excelx}

  def read_from_excel(file_name, sheet_id, &callback)
    ignored_records_count = 0
    file = handler(file_name)
    file.default_sheet = file.sheets[sheet_id]
    2.upto(file.last_row) do |line|
      extractor = Proc.new{ |column| file.cell(line, column) }
      record = callback.call(extractor)
      unless !record.nil? && record.save
        $stderr.puts "Record: #{record.try(:inspect)}, Errors: #{record.try{|rec| rec.errors.full_messages.join(',')} }"
        ignored_records_count += 1
      end
    end
    $stderr.puts "\n"
    $stderr.puts "#{pluralize(ignored_records_count, 'record')} (out of a total count of #{file.last_row - 1}) ignored due to the above errors" if ignored_records_count > 0
    ignored_records_count == 0 && file.last_row > 2
  end

  private
  def handler(file_name)
    extension = file_name.split(".").last
    EXCEL_HANDLERS[extension].new(file_name)
  end
end
