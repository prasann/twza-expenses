require 'spec_helper'
require 'helpers/excel_data_extractor'

describe "Excel data extractor" do

include ExcelDataExtractor

  it "should extract details from excel" do
    file_name = "file_name"
    sheet_id = 0
    callback = lambda{|extractor| extractor.call}
    file_mock = mock("excel_file", :sheets => [mock("sheet")], :last_row => 3, :cell => "cell", :default_sheet= => "nothing")
    should_receive(:handler).with(file_name).and_return(file_mock)
    file_mock.should_receive(:cell).twice
    read_from_excel(file_name, sheet_id, &callback)
  end
end
