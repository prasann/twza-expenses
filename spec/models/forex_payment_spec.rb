require 'spec_helper'

describe 'forex_payment' do
 
  before(:each) do
	ForexPayment.delete_all
  end

  it 'should be able to fetch forex paid to an employee between dates' do
	forex_1 = ForexPayment.create({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=12)})
	forex_2 = ForexPayment.create({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=14)})
	forex_3 = ForexPayment.create({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=17)})
	forex_4 = ForexPayment.create({:emp_id => '122', :travel_date => Date.new(y=2011, m=12, d=14)})
	forex_5 = ForexPayment.create({:emp_id => '121', :travel_date => Date.new(y=2011, m=12, d=14)})

	valid_forex_payments = ForexPayment.fetch_for '123', Date.new(y=2011, m=12, d=13), Date.new(y=2011, m=12, d=17)
	valid_forex_payments.count.should ==2
	valid_forex_payments.should include forex_2
	valid_forex_payments.should include forex_3
  end
end
