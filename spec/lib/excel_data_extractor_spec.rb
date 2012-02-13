require 'spec_helper'
require 'helpers/excel_data_extractor'

describe "Excel data extractor" do

include ExcelDataExtractor

  it "should extract details from excel" do
    file_name = "file_name"
    sheet_id = 0
    mockObject = mock(Object, :save => 'nothing', :errors => {})
    mockObjectWithValidationErrors = mock(Object, :save => 'nothing',
                                          :errors => mock(Mongoid::Errors, :empty? => false,
                                                          :messages => {:validation_error => 'Invalid data'}))
    mockObjectWithDbErrors = mock(Object, :save => 'nothing',:errors => {})
    mockObjectWithDbErrors.should_receive(:save!).and_raise('Test DB Error message')
    callback = lambda{|extractor| extractor.call}
    file_mock = mock("excel_file", :sheets => [mock("sheet")], :last_row => 4, :default_sheet= => "nothing")
    file_mock.should_receive(:cell).with(2, anything).and_return(mockObject)
    file_mock.should_receive(:cell).with(3, anything).and_return(mockObjectWithValidationErrors)
    file_mock.should_receive(:cell).with(4, anything).and_return(mockObjectWithDbErrors)
    should_receive(:handler).with(file_name).and_return(file_mock)
    mockObject.should_receive(:save!)
    mockObjectWithValidationErrors.should_receive(:save!)
    should_receive(:show_ignored_records_summary).with(1)
    should_receive(:show_exception_records_summary).with(1)
    read_from_excel(file_name, sheet_id, &callback)
  end
end
