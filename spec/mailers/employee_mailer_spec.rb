require 'spec_helper'

describe EmployeeMailer do
  describe 'travel expense settlement' do
    before(:each) do
      @employee_id = 1
      @travel_id = 1
      @profile = mock(Profile, :employee_id => @employee_id, :email_id => 'johns', :common_name => 'John Smith', :get_full_name => 'John_Smith')
      @forex = Factory(:forex_payment)
      travel = mock(OutboundTravel, :__id__ => @travel_id, :place => 'UK', :departure_date => Time.parse('2011-10-01'))
      @expense_report = mock(ExpenseSettlement, :empl_id => @employee_id, :cash_handovers => [], :outbound_travel => travel)
      @expense_report.should_receive(:populate_instance_data)
      expense = {"report_id" => 123, "currency" => 'USD', "amount" => 1000, "conversion_rate" => 52.30, "local_currency_amount" => 52300}
      @expense_report.populate_instance_data
      @expense_report.stub(:profile).and_return(@profile)
      @expense_report.stub(:employee_email).and_return('johns' + ::Rails.application.config.email_domain)
      @expense_report.stub(:get_consolidated_expenses).and_return([expense])
      @expense_report.stub(:get_forex_payments).and_return([@forex])
      @expense_report.stub(:get_conversion_rate).and_return(expense["conversion_rate"])
      @expense_report.stub(:get_receivable_amount).and_return(52300)
    end

    it "should render successfully" do
      lambda { EmployeeMailer.expense_settlement(@expense_report).deliver }.should_not raise_error
    end

    describe "rendered without error" do
      before(:each) do
        @email = EmployeeMailer.expense_settlement(@expense_report)
      end

      it "should have the e-mail components properly set" do
        @email.to.size.should == 1
        @email.to[0].should == @profile.email_id + ::Rails.application.config.email_domain
        @email.from.size.should == 1
        @email.from[0].should == ::Rails.application.config.email_sender
        @email.subject.should == 'test - ' + EmployeeMailer::EXPENSE_SETTLEMENT_SUBJECT.sub('$place','UK').sub('$start_date','01-Oct-2011')
        @email.body.should include(@expense_report.get_receivable_amount)
      end

      it "should have receivable amount" do
        @email.body.should include(@expense_report.get_receivable_amount)
      end
    end
  end
end
