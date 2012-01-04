require 'excel_data_extractor'

class TravelDataImporter
  include ExcelDataExtractor

  def import(from_file)
    read_from_excel(from_file,0) do |extractor|
      begin
        OutboundTravel.create(emp_id: extractor.call("B"),
                              emp_name: extractor.call("C"), place: extractor.call("D"),
                              travel_duration: extractor.call("E"), payroll_effect: extractor.call("F"),
                              departure_date: to_date(extractor.call("G")), foreign_payroll_transfer: to_str(extractor.call("H")),
                              return_date: to_date(extractor.call("I")), return_payroll_transfer: to_str(extractor.call("J")),
                              expected_return_date: to_str(extractor.call("K")), project: extractor.call("L"),
                              comments: extractor.call("M"), actions: extractor.call("N"))
      rescue => e
        puts "Error while processing the record:
           # Record No: #{extractor.call('A') }  
           # Employee Name: #{extractor.call('C') }
           # Travelling To: #{extractor.call('D')}
           # Date of Travel: #{extractor.call('G')} "
      end
    end
  end

  def to_date(cell_value)
    return (cell_value.instance_of?Date) ? cell_value : nil
  end

  def to_str(cell_value)
    return (cell_value.instance_of?Date) ? cell_value.to_s : cell_value
  end
end

