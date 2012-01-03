require 'excel_data_extractor'

class TravelDataImporter
  include ExcelDataExtractor

  def import(from_file)
    read_from_excel(from_file,1) do |extractor|
      begin
        OutboundTravel.create(emp_id: extractor.call("B"),
                              emp_name: extractor.call("C"), place: extractor.call("D"),
                              travel_duration: extractor.call("E"), payroll_effect: extractor.call("F"),
                              departure_date: extractor.call("G"), foreign_payroll_transfer: extractor.call("H"),
                              return_date: extractor.call("I"), return_payroll_transfer: extractor.call("J"),
                              expected_return_date: extractor.call("K"), project: extractor.call("L"),
                              comments: extractor.call("M"), actions: extractor.call("N"))
      rescue
        puts "Error while processing the record:
        Employee Name: #{extractor.call('C') }
        Travelling To: #{extractor.call('D')}
        Date of Travel: #{extractor.call('G')} "
      end
    end
  end
end

