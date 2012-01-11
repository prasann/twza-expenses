require "spec_helper"

describe EmployeeMailer do
  before(:each) do
    employee_id = 1
    travel_id = 1
    @profile = Profile.stub(:employee_id => employee_id, :email => 'padmana@thoughtworks.com')
    forex = mock(ForexPayment)
    expense = mock(Expense)
    travel = mock(OutboundTravel, :__id__ => travel_id)
    @expense_report = ExpenseReport.stub(
        :empl_id => employee_id, :forex => [forex], :expense => [expense], :travel_id => travel_id
    )
  end

  it "should send emails" do
    email = EmployeeMailer.expense_settlement(@profile,@expense_report).deliver
    ActionMailer::Base.deliveries.empty?.should == false
    email.to.size.should == 1
    email.to[0].should == @profile[:email]
    email.from.size.should == 1
    email.from[0].should == EmployeeMailer.class_variable_get(:@@SENDER)
    email.subject.should == EmployeeMailer.class_variable_get(:@@EXPENSE_SETTLEMENT_SUBJECT)
  end
end
