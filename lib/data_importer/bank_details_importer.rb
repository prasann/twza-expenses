require 'helpers/excel_data_extractor'

class BankDetailsImporter
  include ExcelDataExtractor

  def import(from_file)
    read_from_excel(from_file, 0) do |extractor|
      begin
        BankDetail.create(empl_id: extractor.call("B"),
                          empl_name: extractor.call("C"), 
                          account_no: extractor.call("D")) 
      rescue
        puts "Error while processing the record:
        Employee Name: #{extractor.call('C') }
        Account No: #{extractor.call('D')} "
      end

    end
  end
end
