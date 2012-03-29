require 'spec_helper'

describe NumberHelper do
  include NumberHelper

  describe "format decimal numbers" do
    it "should format decimal number to two decimal places" do
      format_two_decimal_places(5678.35660).should == 5678.36
    end
  end
end
