require 'spec_helper'

describe "Excel data extractor" do
  include ExcelDataExtractor

  it "should extract details from excel" do
    file_name = "file_name"
    sheet_id = 0
    mockObject = mock('Object', :save => 'nothing', :errors => {})
    mockObjectWithValidationErrors = mock('Object', :errors => mock('Mongoid::Errors', :full_messages => ['something is really bad']))
    callback = lambda{|extractor| extractor.call}
    file_mock = mock("excel_file", :sheets => [mock("sheet")], :last_row => 3, :default_sheet= => "nothing")
    file_mock.should_receive(:cell).with(2, anything).and_return(mockObject)
    file_mock.should_receive(:cell).with(3, anything).and_return(mockObjectWithValidationErrors)
    self.should_receive(:handler).with(file_name).and_return(file_mock)
    mockObject.should_receive(:save).and_return(true)
    mockObjectWithValidationErrors.should_receive(:save).and_return(false)
    self.should_receive(:show_summary)

    read_from_excel(file_name, sheet_id, &callback)
  end
end
