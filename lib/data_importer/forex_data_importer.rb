require 'helpers/excel_data_extractor'

class ForexDataImporter
  include ExcelDataExtractor

  def import(from_file)
    read_from_excel(from_file, 0) do |extractor|
      ForexPayment.new(issue_date: extractor.call("B"),
                       emp_id: extractor.call("C"), emp_name: extractor.call("D"),
                       amount: extractor.call("E"), currency: extractor.call("F"),
                       travel_date: extractor.call("G"), place: extractor.call("H"),
                       project: extractor.call("I"), vendor_name: extractor.call("J"),
                       card_number: extractor.call("K"), expiry_date: extractor.call("L"),
                       office: extractor.call("M"), inr: extractor.call("N"))
    end
  end
end
