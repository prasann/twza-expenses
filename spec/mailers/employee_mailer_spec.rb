require 'spec_helper'

describe EmployeeMailer do
  describe 'expense_settlement' do
    before(:each) do
      @employee_id = 1
      @profile = Profile.new(:employee_id => @employee_id, :email_id => 'johns', :common_name => 'John Smith', :name => 'John', :surname => 'Smith')
      forex = FactoryGirl.create(:forex_payment)
      travel = FactoryGirl.create(:outbound_travel, :place => 'UK', :departure_date => Time.parse('2011-10-01'))
      @travel_id = travel.id
      @expense_settlement = FactoryGirl.create(:expense_settlement, :empl_id => @employee_id, :cash_handovers => [], :outbound_travel => travel)
      expense = {"report_id" => 123, "currency" => 'USD', "amount" => 1000, "conversion_rate" => 52.30, "local_currency_amount" => 52300}
      @expense_settlement.should_receive(:profile).and_return(@profile)
      @expense_settlement.should_receive(:employee_email).and_return('johns' + ::Rails.application.config.email_domain)
      @expense_settlement.should_receive(:get_consolidated_expenses).and_return([expense])
      @expense_settlement.should_receive(:get_forex_payments).and_return([forex])
      # @expense_settlement.should_receive(:get_conversion_rate).and_return(expense["conversion_rate"])
      @expense_settlement.should_receive(:get_receivable_amount).at_least(2).times.and_return(52300)
    end

    it "should render successfully" do
      lambda { EmployeeMailer.expense_settlement(@expense_settlement).deliver }.should_not raise_error
    end

    describe "rendered without error" do
      before(:each) do
        @email = EmployeeMailer.expense_settlement(@expense_settlement)
      end

      it "should have the e-mail components properly set" do
        @email.to.size.should == 1
        @email.to[0].should == @profile.email_id + ::Rails.application.config.email_domain
        @email.from.size.should == 1
        @email.from[0].should == ::Rails.application.config.email_sender
        @email.subject.should == 'test - ' + EmployeeMailer::EXPENSE_SETTLEMENT_SUBJECT.sub('$place','UK').sub('$start_date','01-Oct-2011')
        @email.body.should include(@expense_settlement.get_receivable_amount)
      end

      it "should have receivable amount" do
        @email.body.should include(@expense_settlement.get_receivable_amount)
      end
    end
  end

  describe "non_travel_expense_reimbursement" do
    it "should be tested"
  end
end
