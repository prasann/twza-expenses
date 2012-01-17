require 'spec_helper'
require 'date'

describe ApplicationHelper do
  describe "format date" do

    it "should format date properly" do

      date = DateTime.parse('2011-10-01')
      actual_formatted_date = date_fmt(date)
      actual_formatted_date.should eq '01-Oct-2011'
    end
  end


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
end