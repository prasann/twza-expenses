require 'spec_helper'

describe 'forex_payment' do
 
  before(:each) do
	ForexPayment.delete_all
  end

  def valid_attributes
    {:emp_id => '123', :emp_name => 'test', :amount => 120.25, :currency => 'INR', :travel_date => Date.today, 
     :office => 'Chennai', :inr => 5001.50}
  end

  it 'should be able to fetch forex paid to an employee between dates' do
	forex_1 = ForexPayment.create(valid_attributes.merge!({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=12)}))
	forex_2 = ForexPayment.create(valid_attributes.merge!({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=14)}))
	forex_3 = ForexPayment.create(valid_attributes.merge!({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=17)}))
	forex_4 = ForexPayment.create(valid_attributes.merge!({:emp_id => '122', :travel_date => Date.new(y=2011, m=12, d=14)}))
	forex_5 = ForexPayment.create(valid_attributes.merge!({:emp_id => '121', :travel_date => Date.new(y=2011, m=12, d=14)}))

	valid_forex_payments = ForexPayment.fetch_for '123', Date.new(y=2011, m=12, d=13), Date.new(y=2011, m=12, d=17),[]
	valid_forex_payments.count.should ==2
	valid_forex_payments.should include forex_2
	valid_forex_payments.should include forex_3
  end

  it "should not save without the presence of :emp_id, :emp_name, :amount, :currency, :travel_date, :office, :inr" do
    forex_payment = ForexPayment.new()
    forex_payment.valid?.should be_false
    error_msgs = forex_payment.errors.messages
    error_msgs.each do |k,v|
      error_msgs[k].should == ["can't be blank"]
    end
  end
end
