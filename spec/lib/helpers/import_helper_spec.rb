require 'spec_helper'

describe ImportHelper do
  describe "return valid dates" do
    it "should return if date is passed and nil otherwise" do
      value = ImportHelper::to_date(Date.strptime('01/2012', '%m/%Y'))
      value.should_not be_nil
      (value.is_a?Date).should be_true
      ImportHelper::to_date('ABC').should be_nil
    end
  end

  describe "convert date to string if valid" do
    it "should convert date to string if it is valid and nil otherwise" do
      value = ImportHelper::to_str(Date.strptime('01/2012', '%m/%Y'))
      value.should_not be_nil
      value.should == '2012-01-01'
      ImportHelper::to_str('AG').should == 'AG'
    end
  end

  describe "pluralize a string" do
    it "should pluralize if count is greater than 1 with the given word" do
      value = ImportHelper::pluralize(3,'child','children')
      value.should == '3 children'
      value = ImportHelper::pluralize(3,'book')
      value.should == '3 books'
    end

    it "should not pluralize if count is equal to 1" do
      value = ImportHelper::pluralize(1,'child','children')
      value.should == '1 child'
    end
  end
end
