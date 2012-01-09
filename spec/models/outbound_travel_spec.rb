require 'spec_helper'

describe OutboundTravel do
  it "should not savewithout the presense of emp_id, emp_name, departure_date, expected_return_date" do
    outbound_travel = OutboundTravel.new
    outbound_travel.valid?.should be_false
    error_msgs = outbound_travel.errors.messages
    error_msgs.size.should be 4
    [:emp_id, :emp_name, :departure_date, :expected_return_date].each do |k|
      error_msgs[k].should == ["can't be blank"]
    end
  end
end
