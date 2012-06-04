class EmployeeDetailsImporter
  include ExcelDataExtractor

  def import(from_file)
    read_from_excel(from_file, 0) do |extractor|
      EmployeeDetail.new(emp_id: extractor.call("B"),
                     emp_name: extractor.call("A"),
                     email: extractor.call("C"))
    end
  end
end