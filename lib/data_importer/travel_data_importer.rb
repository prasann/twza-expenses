require 'helpers/import_helper'
require 'helpers/excel_data_extractor'

class TravelDataImporter
  include ExcelDataExtractor

  def import(from_file)
    ignored_records_count = 0
    read_from_excel(from_file, 0) do |extractor|
      begin
        OutboundTravel.new(emp_id: extractor.call("B"),
                           emp_name: extractor.call("C"), place: extractor.call("D"),
                           travel_duration: extractor.call("E"), payroll_effect: extractor.call("F"),
                           departure_date: ImportHelper::to_date(extractor.call("G")),
                           foreign_payroll_transfer: ImportHelper::to_str(extractor.call("H")),
                           return_date: ImportHelper::to_date(extractor.call("I")),
                           return_payroll_transfer: ImportHelper::to_str(extractor.call("J")),
                           expected_return_date: ImportHelper::to_str(extractor.call("K")),
                           project: extractor.call("L"),comments: extractor.call("M"), actions: extractor.call("N"))

      end
    end
  end


end
