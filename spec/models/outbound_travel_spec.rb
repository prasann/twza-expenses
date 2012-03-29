require 'spec_helper'

describe OutboundTravel do

  describe "find_or_initialize_expense_settlement" do
    it "should create expense_settlement if none present for the travel" do
      outbound_travel = Factory.build(:outbound_travel)
      outbound_travel.should_receive(:create_expense_settlement)

      actual = outbound_travel.find_or_initialize_expense_settlement
      actual.should == outbound_travel.expense_settlement
    end
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

  describe "get_json_to_populate" do
    it "should populate unique and non nullable data for auto suggestion" do
      outbound_travel_1 = Factory(:outbound_travel, :place => 'US')
      outbound_travel_2 = Factory(:outbound_travel, :place => 'US', :payroll_effect => '100%')
      fields = OutboundTravel.get_json_to_populate('place', 'payroll_effect')
      fields.should be_eql ({'place' => ["US"], 'payroll_effect' => ["100%"]})
    end

    it "should strip the values and then keep uniques"

    it "should remove nils from the result"
  end

  describe "fields" do
    let(:outbound_travel) { Factory(:outbound_travel) }

    it { should contain_field(:emp_id, :type => Integer) }
    it { should contain_field(:emp_name, :type => String) }
    it { should contain_field(:place, :type => String) }
    it { should contain_field(:travel_duration, :type => String) }
    it { should contain_field(:payroll_effect, :type => String) }
    it { should contain_field(:departure_date, :type => Date) }
    it { should contain_field(:foreign_payroll_transfer, :type => String) }
    it { should contain_field(:return_date, :type => Date) }
    it { should contain_field(:return_payroll_transfer, :type => String) }
    it { should contain_field(:expected_return_date, :type => String) }
    it { should contain_field(:project, :type => String) }
    it { should contain_field(:comments, :type => String) }
    it { should contain_field(:actions, :type => String) }
    xit { should have_one(:expense_settlement) }
  end

  describe "validations" do
    it { should validate_presence_of(:emp_id) }
    it { should validate_presence_of(:emp_name) }
    it { should validate_presence_of(:departure_date) }
    it { should validate_presence_of(:place) }
  end

end
