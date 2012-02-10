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

  it "should validate credit card number" do
    forex_with_invalid_card = ForexPayment.create(valid_attributes.merge!({:card_number => '1234 3214 3212 323223 Axis'}))
    forex_with_invalid_card.valid?.should be_false
    error_msgs = forex_with_invalid_card.errors.messages
    error_msgs.each do |k, v|
      error_msgs[k].should include ForexPayment::INVALID_CREDIT_CARD_MSG
    end

    forex_with_valid_card = ForexPayment.create(valid_attributes.merge!({:card_number => '1234 3214 3212 3243 Axis',
                                                                        :expiry_date => Date.today + 100}))
    forex_with_valid_card.errors.messages.size.should be 0
  end

  it "should verify if credit card expiry date is specified if card number is specified" do
    forex_without_expiry_date = ForexPayment.create(valid_attributes.merge!({:card_number => '1234 3214 3212 3243 Axis'}))
    forex_without_expiry_date.valid?.should be_false
    error_msgs = forex_without_expiry_date.errors.messages
    error_msgs.each do |k, v|
      error_msgs[k].should include ForexPayment::MISSING_EXPIRY_DATE_MSG
    end
  end

end
