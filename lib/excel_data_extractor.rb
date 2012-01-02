require 'roo'

module ExcelDataExtractor

  EXCEL_HANDLERS = {"xls" => Excel, "xlsx" => Excelx}

  def read_from_excel(file_name, sheet_id, &callback)
    file = handler(file_name)
    file.default_sheet = file.sheets[sheet_id]
    2.upto(file.last_row) do |line|
        extractor = Proc.new{|column|
                           file.cell(line, column)
                    }
        callback.call(extractor)
    end
  end

  def handler(file_name)
    extension= file_name.split(".").last
    EXCEL_HANDLERS[extension].new(file_name)
  end

end
