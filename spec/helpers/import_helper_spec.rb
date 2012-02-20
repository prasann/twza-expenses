require 'spec_helper'
require 'date'

describe ImportHelper do
  describe "return valid dates" do
    it "should return if date is passed and nil otherwise" do
      value = ImportHelper::to_date(Date.strptime('01/2012', '%m/%Y'))
      value.should_not be nil
      (value.is_a?Date).should be true
      ImportHelper::to_date('ABC').should be nil
    end
  end

  describe "convert date to string if valid" do
    it "should convert date to string if it is valid and nil otherwise" do
      value = ImportHelper::to_str(Date.strptime('01/2012', '%m/%Y'))
      value.should_not be nil
      value.should == '2012-01-01'
      ImportHelper::to_str('AG').should == 'AG'
    end
  end

  describe "pluralize words" do
    it "should pluralize words properly based on count" do
      ImportHelper.pluralize(1, 'record').should eq '1 record'
      ImportHelper.pluralize(10, 'record').should eq '10 records'
      ImportHelper.pluralize(10, 'match', 'matches').should eq '10 matches'
    end
  end
end
