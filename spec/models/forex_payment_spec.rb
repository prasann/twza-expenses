require 'spec_helper'

describe 'forex_payment' do
  before(:each) do
    ForexPayment.delete_all
  end

  # TODO: Use factory_girl
  def valid_attributes
    {:emp_id => '123', :emp_name => 'test', :amount => 120.25, :currency => 'INR', :travel_date => Date.today,
     :office => 'Chennai', :inr => 5001.50, :vendor_name => 'VKC Forex', :issue_date => Date.today - 2 }
  end

  it 'should be able to fetch forex paid to an employee between dates' do
    forex_1 = ForexPayment.create(valid_attributes.merge!({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=12)}))
    forex_2 = ForexPayment.create(valid_attributes.merge!({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=14)}))
    forex_3 = ForexPayment.create(valid_attributes.merge!({:emp_id => '123', :travel_date => Date.new(y=2011, m=12, d=17)}))
    forex_4 = ForexPayment.create(valid_attributes.merge!({:emp_id => '122', :travel_date => Date.new(y=2011, m=12, d=14)}))
    forex_5 = ForexPayment.create(valid_attributes.merge!({:emp_id => '121', :travel_date => Date.new(y=2011, m=12, d=14)}))

    valid_forex_payments = ForexPayment.fetch_for '123', Date.new(y=2011, m=12, d=13), Date.new(y=2011, m=12, d=17),[]
    valid_forex_payments.count.should == 2
    valid_forex_payments.should include(forex_2)
    valid_forex_payments.should include(forex_3)
  end

  it "should not save without the presence of mandatory attributes" do
    forex_payment = ForexPayment.new
    forex_payment.valid?.should be_false
    error_msgs = forex_payment.errors.messages
     error_msgs.each do |k, v|
      error_msgs[k].should == ["can't be blank"]
    end
  end

  describe "Populate Autosuggest data" do
    it "should populate unique and non nullable data for auto suggestion" do
      outbound_travel_1 = Factory(:forex_payment, :place => 'US', :currency => 'GBP', :office => 'Pune')
      outbound_travel_2 = Factory(:forex_payment, :place => 'US', :vendor_name => 'VFC', :currency => 'USD', :office => 'Chennai')

      fields = ForexPayment.get_json_to_populate('place','vendor_name','currency')

      fields.should be_eql ({'place' => ["US"], 'vendor_name' => ['VKC Forex', 'VFC'], 'currency' => ['GBP','USD']})
    end

    it "should strip the values and then keep uniques"

    it "should remove nils from the result"
  end
end
