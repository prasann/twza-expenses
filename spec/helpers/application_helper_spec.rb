require 'spec_helper'
require 'date'

describe ApplicationHelper do
  describe "format decimal numbers" do
    it "should format decimal number to two decimal places" do
      format_two_decimal_places(5678.35660).should == 5678.36
    end
  end

  describe "prepare flash message HTML for UI" do
    it "should create escaped HTML for flash message for display in UI" do
      flash[:error] = 'Could not save expense report'
      flash[:success] = 'Email sent successfully'

      message = flash_message
      message.should include "<div class=\"error notification\">Could not save expense report</div>"
      message.should include "<div class=\"success notification\">Email sent successfully</div>"
      message.should include javascript_tag('$(\'.notification\').fadeOut(5000);')
    end
  end

  describe "calculate duration of stay" do
    it "should calculate days from expected return date" do
      outbound_travel = OutboundTravel.create! ({emp_id: 123, emp_name: 'Emp' , departure_date: Date.new(2012,2,15),expected_return_date: '19/02/2012'})
      calculate_stay_duration(outbound_travel).should == 4
    end

    it "should calculate days from actual return date if available" do
      outbound_travel = OutboundTravel.create! ({emp_id: 123, emp_name: 'Emp' , departure_date: Date.new(2012,2,15),expected_return_date: '19/02/2012', return_date: Date.new(2012,2,21)})
      calculate_stay_duration(outbound_travel).should == 6
    end
  end
end
