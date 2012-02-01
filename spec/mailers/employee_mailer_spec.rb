require "spec_helper"

describe EmployeeMailer do

  describe 'travel expense settlement' do
    before(:each) do
      @employee_id = 1
      @travel_id = 1
      @profile = mock(Profile,:employee_id => @employee_id, :email_id => 'johns', :common_name => 'John Smith', :get_full_name => 'John_Smith')
      @forex = ForexPayment.create(
      :attributes =>
      {
        :emp_id => '123', :emp_name => 'test', :amount => 120.25, :currency => 'INR',
        :travel_date => Date.today, :office => 'Chennai', :inr => 5001.50
      }
      )
      @expense = Expense.create(
      :attributes =>
      {
        :currency => 'USD', :amount=>1000, :conversion_rate=> 52.30
      }
      )
      travel = mock(OutboundTravel, :__id__ => @travel_id, :place=>'UK', :departure_date => Time.parse('2011-10-01'))
      @expense_report = mock(ExpenseSettlement, :empl_id => @employee_id, :cash_handover => 0, :outbound_travel => travel)
      @expense_report.should_receive(:populate_instance_data)
      expense = Hash.new
      expense['report_id'] = @expense[:expense_rpt_id]
      expense['currency'] = @expense[:currency]
      expense['amount'] = @expense[:amount]
      expense['conversion_rate'] = @expense[:conversion_rate]
      expense['local_currency_amount'] = 52300
      @expense_report.populate_instance_data
      @expense_report.stub(:profile).and_return(@profile)
      @expense_report.stub(:get_consolidated_expenses).and_return([expense])
      @expense_report.stub(:get_forex_payments).and_return([@forex])
      @expense_report.stub(:get_conversion_rate).and_return(@expense[:conversion_rate])
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
        @email.to[0].should == @profile.email_id+::Rails.application.config.email_domain
        @email.from.size.should == 1
        @email.from[0].should == ::Rails.application.config.email_sender
        @email.subject.should == EmployeeMailer::EXPENSE_SETTLEMENT_SUBJECT.sub('$place','UK')
        .sub('$start_date','01-Oct-2011')
        @email.body.should include(@expense_report.get_receivable_amount)
      end

      it "should have receivable amount" do
        @email.body.should include(@expense_report.get_receivable_amount)
      end

      it "should have use employee id and domain to send e-mail if email_id is not available" do
        @profile.stub(:email_id).and_return('')
        @email = EmployeeMailer.expense_settlement(@expense_report)
        @email.to.size.should == 1
        @email.to[0].should == @employee_id.to_s+::Rails.application.config.email_domain
        @email.from.size.should == 1
        @email.from[0].should == ::Rails.application.config.email_sender
        @email.subject.should == EmployeeMailer::EXPENSE_SETTLEMENT_SUBJECT.sub('$place','UK')
        .sub('$start_date','01-Oct-2011')
        @email.body.should include(@expense_report.get_receivable_amount)
      end
    end
  end
end
