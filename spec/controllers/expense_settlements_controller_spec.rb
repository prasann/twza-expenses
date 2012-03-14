require 'spec_helper'
require 'factory_girl'

describe ExpenseSettlementsController do
  before(:each) do
    @criteria_mock = mock(Mongoid::Criteria)
    @expense_settlements = [Expense.new]
  end


  describe "load by travel" do
    it "should load the forex and expenses for the given expense id" do
      currency = 'GBP'
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => Date.today + 5)
      mockProcessedExpenses = [mock("expense", :expenses => [[2]], :forex_payments => [[3]])]
      mockExpenseReportCriteria = mock("Criteria", :to_a => mockProcessedExpenses)
      expenses = [Factory(:expense, :original_currency => currency, :original_cost => 100, :cost_in_home_currency => 8900)]
      mockForex = mock(ForexPayment, :currency => currency, :id => 1)
      forex_payments = [mockForex]
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)

      ExpenseSettlement.should_receive(:where).with({:processed => true}).and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:and).with(:empl_id => "1").and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:only).with(:expenses, :forex_payments).and_return(mockProcessedExpenses)

      Expense.should_receive(:fetch_for_employee_between_dates).with(1, outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                                     outbound_travel.return_date + ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY, [2]).and_return(expenses)

      ForexPayment.should_receive(:fetch_for).with(1, outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                   outbound_travel.return_date, [3]).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:empl_id=>1,:outbound_travel_id=>"123",
                                                          :expenses => expenses.collect(&:id),
                                                          :forex_payments => forex_payments.collect(&:id),
                                                          :cash_handovers=>[])

      get :load_by_travel, :id => 123

      assigns(:expense_report).should have_same_attributes_as expected_expense_settlement
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
    end

    it "should show forex and travel properly for the given expense id even if return travel date is nil" do
      currency = 'GBP'
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => nil)
      expenses = [Factory(:expense, :original_currency => currency, :original_cost => 100, :cost_in_home_currency => 8900)]
      mockForex = mock(ForexPayment, :currency => currency, :id => 1)
      forex_payments = [mockForex]
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)
      Expense.should_receive(:fetch_for_employee_between_dates).with(1, outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                                     nil, []).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(1, outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                   nil, []).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:empl_id=>1,:outbound_travel_id=>"123",
                                                          :expenses => expenses.collect(&:id),
                                                          :forex_payments => forex_payments.collect(&:id),
                                                          :cash_handovers=>[])

      get :load_by_travel, :id => 123

      assigns(:expense_report).should have_same_attributes_as expected_expense_settlement
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
      assigns(:expenses_to_date).should == nil
      assigns(:forex_to_date).should == nil
    end

    it "should use the date for forex and expenses if they are passed as params" do
      currency = 'GBP'
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => Date.today + 5)
      mockProcessedExpenses = [mock("expense", :expenses => [[2]], :forex_payments => [[3]])]
      mockExpenseReportCriteria = mock("Crietria", :to_a => mockProcessedExpenses)
      expenses = [Factory(:expense, :original_currency => currency, :original_cost => 100, :cost_in_home_currency => 8900)]
      mockForex = mock(ForexPayment, :currency => currency, :id => 1)
      forex_payments = [mockForex]
      forex_from, forex_to, expense_to, expense_from = Date.today, Date.today + 1, Date.today + 2, Date.today + 3
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)
      ExpenseSettlement.should_receive(:where).with({:processed => true}).and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:and).with(:empl_id => "1").and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:only).with(:expenses, :forex_payments).and_return(mockProcessedExpenses)
      Expense.should_receive(:fetch_for_employee_between_dates).with(1, expense_from, expense_to, [2]).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(1, forex_from, forex_to, [3]).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:empl_id=>1,:outbound_travel_id=>"123",:cash_handovers=>[],
                                                          :expenses => expenses.collect(&:id),
                                                          :forex_payments => forex_payments.collect(&:id))

      get :load_by_travel, :id => 123, :forex_from => forex_from, :forex_to => forex_to, :expense_from => expense_from, :expense_to => expense_to

      assigns(:expense_report).should have_same_attributes_as expected_expense_settlement
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
    end
  end
  describe "GET 'index'" do
    it "index expenses from db for emplid" do
      ExpenseSettlement.stub_chain(:where, :page, :per).and_return(@expense_reports)
      get :index, :empl_id => 1
      assigns(:expense_settlements).should == @expense_reports
      response.should be_success
    end
  end

  employee_name = 'John Smith'
  describe "POST 'notify'" do
    it "should send notification to employee upon expense settlement computation" do
      expense_report_id = '1'
      employee_id = 1
      mock_profile = mock(Profile, :employee_id => employee_id, :common_name => employee_name)
      expense_report = mock("expense_settlement", :empl_id => employee_id, :populate_instance_data => "nothing",
                            :profile => mock_profile)
      ExpenseSettlement.should_receive(:find).with(expense_report_id).and_return(expense_report)
      EmployeeMailer.stub(:expense_settlement).and_return(mock('mailer', :deliver => 'nothing'))
      expense_report.should_receive(:notify_employee)
      expense_report.should_receive(:profile).and_return(mock_profile)

      post :notify, :id => expense_report_id

      flash[:success].should == "Expense settlement e-mail successfully sent to 'John Smith'"
      response.should redirect_to(:action => :index, :anchor => 'expense_settlements', :empl_id => employee_id)
    end
  end

  describe "edit expense settlement" do
    it "should allow to edit an already created expense settlement" do
      currency = 'EUR'
      empl_id = 1
      expense_from = Date.today - 5.days
      expense_to = Date.today - 3.days
      forex_from = Date.today - 6.days
      forex_to = Date.today - 4.days
      outbound_travel = OutboundTravel.new(:emp_id => empl_id, :emp_name => 'John', :departure_date => Date.today,
                                          :place => 'UK')
      forex_payment = Factory(:forex_payment, :currency => currency)
      expense = Factory(:expense, :empl_id => empl_id,  :original_currency => currency,
                                          :original_cost => 50, :cost_in_home_currency => 7200)
      expense_settlement = ExpenseSettlement.new(:empl_id => empl_id, :expenses => [1], :forex_payments => [1],
                                                 :status => ExpenseSettlement::GENERATED_DRAFT,
                                                  :expense_from => DateHelper::date_fmt(expense_from),
                                                  :expense_to => DateHelper::date_fmt(expense_to),
                                                  :forex_from => DateHelper::date_fmt(forex_from),
                                                  :forex_to => DateHelper::date_fmt(forex_to),
                                                  :cash_handovers =>
                                                    [CashHandover.new(:amount => 100, :currency => currency,
                                                                      :conversion_rate => 72.50)])
      outbound_travel.save!
      expense_settlement.cash_handovers.map &:save!
      expense_settlement.outbound_travel_id = outbound_travel.id
      expense_settlement.save!
      OutboundTravel.should_receive(:find).with(outbound_travel.id).and_return(outbound_travel)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, forex_from, forex_to, anything)
                      .and_return([forex_payment])
      ForexPayment.should_receive(:find).with([1]).and_return([forex_payment])
      ForexPayment.should_receive(:all).and_return([forex_payment])
      Expense.should_receive(:fetch_for_employee_between_dates)
                      .with(outbound_travel.emp_id, expense_from, expense_to, anything)
                      .and_return([expense])
      Expense.should_receive(:find).with([1]).and_return([expense])
      stub_expense_settlement = mock(Object)
      ExpenseSettlement.should_receive(:includes).with(:cash_handovers, :outbound_travel).and_return(stub_expense_settlement)
      stub_expense_settlement.should_receive(:find).with(expense_settlement.id.to_s).and_return(expense_settlement)

      get :edit, :id => expense_settlement.id

      assigns(:expense_report).should have_same_attributes_as expense_settlement
      assigns(:applicable_currencies).should == [currency]
      assigns(:expenses).should == [expense]
      assigns(:forex_payments).should == [forex_payment]
      assigns(:expenses_from_date).should == expense_from
      assigns(:expenses_to_date).should == expense_to
      assigns(:forex_from_date).should == forex_from
      assigns(:forex_to_date).should == forex_to
    end
  end

  describe "generate report" do
    it "should create expense report for chosen expenses, forex and travel" do
      pending("find how to fix this as '_routes' => nil is added to the hash")
      expense_settlement = ExpenseSettlement.new
      outbound_travel = OutboundTravel.new
      outbound_travel.should_receive(:find_or_initialize_expense_settlement).and_return(expense_settlement)
      OutboundTravel.stub!(:find).with("1").and_return(outbound_travel)
      outbound_travel.should_receive(:create_expense_settlement)
      expense_settlement.should_receive(:update_attributes)
      expense_settlement.should_receive(:populate_instance_data)

      post :generate_report, :travel_id => 1

      assigns(@expense_report).should == expense_settlement
    end

    it "should update expense report if it already exists in the travel" do
      pending("find how to fix this as '_routes' => nil is added to the hash")
      expense_settlement = ExpenseSettlement.new
      outbound_travel = OutboundTravel.new(:expense_settlement => expense_settlement)

      OutboundTravel.stub!(:find).with("1").and_return(outbound_travel)
      outbound_travel.should_not_receive(:create_expense_settlement)
      expense_settlement.should_receive(:update_attributes)
      expense_settlement.should_receive(:populate_instance_data)

      post :generate_report, :travel_id => 1

      assigns(@expense_report).should == expense_settlement
    end
  end

  it "should create all applicable currencies for cash handover properly when forex of multiple currencies are involved" do
      travel_id = '1'
      employee_id = '12321'
      test_forex_currencies = ['EUR', 'GBP']
      expenses = [Factory(:expense, :original_currency => 'EUR', :original_cost => 100, :cost_in_home_currency => 7200)]
      forex_payments = []
      forex_ids = []
      test_forex_currencies.each_with_index do |forex_currency, index|
        forex_payment = Factory(:forex_payment, :currency => test_forex_currencies[index])
        forex_ids << forex_payment.id
        forex_payments << forex_payment
      end

      outbound_travel = mock(OutboundTravel, :place => 'UK', :emp_id => employee_id,
                             :departure_date => Date.today - 10, :return_date => Date.today + 5, :id => travel_id)
      OutboundTravel.stub!(:find).with(travel_id).and_return(outbound_travel)

      Expense.should_receive(:fetch_for_employee_between_dates).with(employee_id, outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                                     outbound_travel.return_date + ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY, []).and_return(expenses)

      ForexPayment.should_receive(:fetch_for).with(employee_id, outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                   outbound_travel.return_date, []).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:outbound_travel_id => travel_id, :empl_id => employee_id,
                                                          :expenses => [expenses[0].id],
                                                          :forex_payments => forex_ids,
                                                          :cash_handovers => [CashHandover.new])

      ForexPayment.should_receive(:get_json_to_populate).with('currency').and_return({'currency' => test_forex_currencies})

      get :load_by_travel, :id => travel_id

      assigns(:expense_report).should have_same_attributes_as expected_expense_settlement
      assigns(:applicable_currencies).should == test_forex_currencies
      assigns(:conversion_rates).should == {'EUR' => '72.0' }.to_json.html_safe
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
    end

    it "should set required model objects properly for view when forex of multiple currencies are involved" do
      currency = 'EUR'
      travel_id = '1'
      employee_id = '12321'
      test_forex_currencies = [currency, 'GBP']

      cash_handovers = [CashHandover.new(:amount => 100, :currency=>currency, :conversion_rate => 72.30),
                        CashHandover.new(:amount => 150, :currency=>'GBP', :conversion_rate => 52.31)]
      handovers = {}
      values_hash = {}

      cash_handovers.each_with_index { |item, index| handovers[index.to_s] = item.declared_attributes}

      forex_payments = [mock(ForexPayment, :id => 1, :currency => currency, :inr => 7200, :amount => 200)]
      ForexPayment.stub!(:find).with(['1']).and_return(forex_payments)

      expenses = [mock(Expense, :id => 1, :expense_rpt_id => 1, :original_currency => currency, :original_cost => 100)]
      Expense.stub!(:find).with(['1']).and_return(expenses)

      expense_settlement = ExpenseSettlement.new(:id => 1,:forex_payments => forex_payments.collect(&:id),
                                :expenses => expenses.collect(&:id), :empl_id => employee_id, :outbound_travel_id => travel_id,
                                :cash_handovers => cash_handovers)
      expense_settlement.stub!(:get_receivable_amount).and_return(13732.5)

      outbound_travel = mock(OutboundTravel, :place => 'UK', :emp_id => employee_id,
                             :departure_date => Date.today - 10, :return_date => Date.today + 5, :id => travel_id)
      outbound_travel.should_receive(:find_or_initialize_expense_settlement).and_return(expense_settlement)
      OutboundTravel.stub!(:find).with(travel_id).and_return(outbound_travel)


      post :generate_report, {:expense_settlement => {:id => expense_settlement.id, :empl_id => employee_id,
                                                     :outbound_travel_id => travel_id, :emp_name => employee_name,
                                                     :cash_handovers_attributes => handovers},
                              :forex_payments => [1], :expenses=> [1]
      }

      assigns(:expense_report).should have_same_attributes_as expense_settlement
      assigns(:expense_report).instance_variable_get('@net_payable').should == 13732.5
    end

  private
  def setup_test_data(expenses,forex_payments,employee_id, travel_id, place_of_visit, outbound_travel, currencies,
      expense_amounts, expense_amounts_inr, forex_amounts, forex_amounts_inr, cash_handovers)
    index = 0
    currencies.length.times do
      expenses << mock(Expense, :id => index, :empl_id => employee_id, :original_currency => currencies[index], :place => place_of_visit,
                       :cost_in_home_currency => expense_amounts_inr[index],  :expense_rpt_id => index,
                       :original_cost => expense_amounts[index])

      forex_payments << mock(ForexPayment, :id => index,:emp_id => employee_id, :currency => currencies[index],
                             :place => place_of_visit, :amount => forex_amounts[index], :inr => forex_amounts_inr[index])
      index = index + 1
    end


    forex_ids = forex_payments.map{|forex| forex.id.to_s }
    ForexPayment.stub!(:find).with(forex_ids).and_return(forex_payments)

    expense_ids = expenses.map{|expense| expense.id.to_s }
    Expense.stub!(:find).with(expense_ids).and_return(expenses)

    ExpenseSettlement.new(:empl_id=>employee_id,:outbound_travel_id=>travel_id,:expenses => expense_ids,
                                                          :forex_payments=>forex_ids,
                                                          :cash_handovers=>cash_handovers)
  end
end
