require 'spec_helper'

describe OutboundTravel do
  it "should not savewithout the presense of emp_id, emp_name, departure_date, expected_return_date" do
    outbound_travel = OutboundTravel.new
    outbound_travel.valid?.should be_false
    error_msgs = outbound_travel.errors.messages
    error_msgs.size.should be 3
    [:emp_id, :emp_name, :departure_date].each do |k|
      error_msgs[k].should == ["can't be blank"]
    end
  end

  xit "should create expense_settlement if none present for the travel" do
  	outbound_travel = OutboundTravel.new
	outbound_travel.stub!(:create_expense_settlement){outbound_travel.expense_settlement = "some hash"}
	outbound_travel.should_receive(:create_expense_settlement)
	result = outbound_travel.find_or_initialize_expense_settlement
	result.should == "some hash"
  end
end
