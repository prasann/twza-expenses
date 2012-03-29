require 'spec_helper'

describe DateHelper do
  describe "date_fmt" do
    it "should format date properly" do
      date = DateTime.parse('2011-10-01')
      actual_formatted_date = DateHelper.date_fmt(date)
      actual_formatted_date.should eq '01-Oct-2011'
    end
  end

  describe "#date_from_str" do
    it "should return a string equiv given a valid date" do
      date = Date.new(2012,2,25)
      DateHelper.date_from_str('25/2/2012').should == date
    end

    it "should return nil for an invalid date" do
      invalid_date = '25/22/2012'
      Date.should_receive(:parse).with(invalid_date).and_raise(RuntimeError)
      DateHelper.date_from_str(invalid_date).should be_nil
    end
  end
end
