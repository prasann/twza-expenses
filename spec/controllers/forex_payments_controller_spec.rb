require 'spec_helper'

describe ForexPaymentsController do

  it "should return all forex payments for a particular employee" do
    forex_payment_raju = ForexPayment.create(issue_date: Date.today, emp_id: 1, emp_name: 'Raju')
    forex_payment_raju_nov = ForexPayment.create(issue_date: Date.today - 2.months, emp_id: 1, emp_name: 'Raju')
    forex_payment_ravi = ForexPayment.create(issue_date: Date.today, emp_id: 2, emp_name: 'Ravi')

    get :index, emp_id: 1

    response.should be_success
    assigns[:forex_payments].should == [forex_payment_raju, forex_payment_raju_nov]
  end
end