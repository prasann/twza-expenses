require 'helpers/excel_data_extractor'

class ForexDataImporter
  include ExcelDataExtractor

  def import(from_file)
    read_from_excel(from_file, 3) do |extractor|
      begin
        ForexPayment.create(issue_date: extractor.call("B"),
                            emp_id: extractor.call("C"), emp_name: extractor.call("D"),
                            amount: extractor.call("E"), currency: extractor.call("F"),
                            travel_date: extractor.call("G"), place: extractor.call("H"),
                            project: extractor.call("I"), vendor_name: extractor.call("J"),
                            card_number: extractor.call("K"), expiry_date: extractor.call("L"),
                            office: extractor.call("M"), inr: extractor.call("N"))
      rescue
        puts "Error while processing the record:
        Employee Name: #{extractor.call('D') }
        Issue Date: #{extractor.call('B')}
        Amount: #{extractor.call('E')} "
      end

    end
  end
end
