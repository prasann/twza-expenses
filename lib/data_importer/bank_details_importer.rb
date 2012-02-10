require 'helpers/excel_data_extractor'

class BankDetailsImporter
  include ExcelDataExtractor

  def import(from_file)
    read_from_excel(from_file, 0) do |extractor|
      BankDetail.new(empl_id: extractor.call("B"),
                     empl_name: extractor.call("C"),
                     account_no: extractor.call("D"))
    end
  end
end
