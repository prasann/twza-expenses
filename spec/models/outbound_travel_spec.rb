require 'spec_helper'

describe OutboundTravel do
  it "should create expense_settlement if none present for the travel" do
    outbound_travel = Factory.build(:outbound_travel)
    outbound_travel.should_receive(:create_expense_settlement)

    outbound_travel.find_or_initialize_expense_settlement
  end

  describe "stay_duration" do
    it "should calculate days from expected return date" do
      outbound_travel = Factory(:outbound_travel, :departure_date => Date.new(2012,2,15), :expected_return_date => '19/02/2012')
      outbound_travel.stay_duration.should == 4
    end

    it "should calculate days from actual return date if available" do
      outbound_travel = Factory(:outbound_travel, :departure_date => Date.new(2012,2,15), :expected_return_date => '19/02/2012', :return_date => Date.new(2012,2,21))
      outbound_travel.stay_duration.should == 6
    end
  end

  describe "Populate autosuggest data" do
    it "should populate unique and non nullable data for auto suggestion" do
      outbound_travel_1 = Factory(:outbound_travel, :place => 'US')
      outbound_travel_2 = Factory(:outbound_travel, :place => 'US', :payroll_effect => '100%')
      fields = OutboundTravel.get_json_to_populate('place', 'payroll_effect')
      fields.should be_eql ({'place' => ["US"], 'payroll_effect' => ["100%"]})
    end

    it "should strip the values and then keep uniques"

    it "should remove nils from the result"
  end
end
