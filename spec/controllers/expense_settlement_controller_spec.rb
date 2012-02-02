require 'spec_helper'

describe ExpenseSettlementController do
  before(:each) do
    @criteria_mock = mock(Mongoid::Criteria)
    @expense_settlements = [Expense.new]
  end

  describe "load by travel" do
    it "should load the forex and expenses for the given expense id" do
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => Date.today + 5)
      mockProcessedExpenses = [mock("expense", :expenses => [[2]], :forex_payments => [[3]])]
      mockExpenseReportCriteria = mock("Criteria", :to_a => mockProcessedExpenses)
      mockExpenses = mock("expenses")
      mockForex = mock("forex")
      mockForex.should_receive(:collect).and_return(['GBP'])
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)

      ExpenseSettlement.should_receive(:where).with({:processed => true}).and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:for_empl_id).with("1").and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:only).with(:expenses, :forex_payments).and_return(mockProcessedExpenses)

      Expense.should_receive(:fetch_for_employee_between_dates).with(1,outbound_travel.departure_date - ExpenseSettlementController::EXPENSE_DATES_PADDED_BY,
      outbound_travel.return_date + ExpenseSettlementController::EXPENSE_DATES_PADDED_BY,[2]).and_return(mockExpenses)

      ForexPayment.should_receive(:fetch_for).with(1,outbound_travel.departure_date - ExpenseSettlementController::FOREX_PAYMENT_DATES_PADDED_BY,
      outbound_travel.return_date, [3]).and_return(mockForex)

      expected_result_hash = Hash.new
      expected_result_hash["expenses"]=mockExpenses
      expected_result_hash["forex_payments"]=mockForex
      expected_result_hash["empl_id"]=1
      expected_result_hash["travel_id"]="123"

      get :load_by_travel, :id => 123

      assigns(:expense_report).should == expected_result_hash
    end

    it "should show forex and travel properly for the given expense id even if return travel date is nil" do
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => nil)
      mockExpenses = mock(Expense)
      mockForex = mock(ForexPayment)
      mockForex.should_receive(:collect).and_return(['GBP'])
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)
      Expense.should_receive(:fetch_for_employee_between_dates).with(1, outbound_travel.departure_date - ExpenseSettlementController::EXPENSE_DATES_PADDED_BY,
                                                                     nil,[]).and_return(mockExpenses)
      ForexPayment.should_receive(:fetch_for).with(1, outbound_travel.departure_date - ExpenseSettlementController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                   nil,[]).and_return(mockForex)
      expected_result_hash = Hash.new
      expected_result_hash["expenses"]=mockExpenses
      expected_result_hash["forex_payments"]=mockForex
      expected_result_hash["empl_id"]=1
      expected_result_hash["travel_id"]="123"

      get :load_by_travel, :id => 123

      assigns(:expense_report).should == expected_result_hash
      assigns(:expenses_to_date).should == nil
      assigns(:forex_to_date).should == nil
    end

    it "should use the date for forex and expenses if they are passed as params" do
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => Date.today + 5)
      mockProcessedExpenses = [mock("expense", :expenses => [[2]], :forex_payments => [[3]])]
      mockExpenseReportCriteria = mock("Crietria", :to_a => mockProcessedExpenses)
      mockExpenses = mock("expenses")
      mockForex = mock("forex")
      mockForex.should_receive(:collect).and_return(['GBP'])
      forex_from, forex_to, expense_to, expense_from = Date.today, Date.today + 1, Date.today + 2, Date.today + 3
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)
      ExpenseSettlement.should_receive(:where).with({:processed => true}).and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:for_empl_id).with("1").and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:only).with(:expenses, :forex_payments).and_return(mockProcessedExpenses)
      Expense.should_receive(:fetch_for_employee_between_dates).with(1,expense_from,expense_to,[2]).and_return(mockExpenses)
      ForexPayment.should_receive(:fetch_for).with(1,forex_from,forex_to,[3]).and_return(mockForex)

      expected_result_hash = Hash.new
      expected_result_hash["expenses"]=mockExpenses
      expected_result_hash["forex_payments"]=mockForex
      expected_result_hash["empl_id"]=1
      expected_result_hash["travel_id"]="123"

      get :load_by_travel, :id => 123, :forex_from => forex_from, :forex_to => forex_to, :expense_from => expense_from, :expense_to => expense_to

      assigns(:expense_report).should == expected_result_hash
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

  describe "POST 'notify'" do
    it "should send notification to employee upon expense settlement computation" do
      expense_report_id = '1'
      employee_id = 1
      mock_profile = mock(Profile, :employee_id => employee_id, :common_name => 'John Smith')
      expense_report = mock("expense_settlement", :empl_id => employee_id, :populate_instance_data => "nothing",
                            :profile => mock_profile)
      ExpenseSettlement.should_receive(:find).with(expense_report_id).and_return(expense_report)
      EmployeeMailer.stub(:expense_settlement).and_return(mock('mailer', :deliver => 'nothing'))
      expense_report.should_receive(:notify_employee)
      expense_report.should_receive(:profile).and_return(mock_profile)

      post :notify, :id => expense_report_id

      flash[:success].should == "Expense settlement e-mail successfully sent to 'John Smith'"
      response.should redirect_to(:action =>:index, :anchor=>'expense_settlement', :empl_id => employee_id)
    end
  end

  describe "generate report" do
    xit "should create expense report for chosen expenses, forex and travel" do
      expense_settlement = ExpenseSettlement.new
      outbound_travel = OutboundTravel.new
      outbound_travel.stub(:create_expense_settlement){outbound_travel.expense_settlement = expense_settlement}
      OutboundTravel.stub!(:find).with("1").and_return(outbound_travel)
      outbound_travel.should_receive(:create_expense_settlement)
      expense_settlement.should_receive(:update_attributes)
      expense_settlement.should_receive(:populate_instance_data)

      post :generate_report, :travel_id => 1

      #TODO: find how to fix this as "_routes" => nil is added to the hash
      #assigns(@expense_report).should == expense_settlement
    end

    xit "should update expense report if it already exists in the travel" do
      expense_settlement = ExpenseSettlement.new
      outbound_travel = OutboundTravel.new(:expense_settlement => expense_settlement)

      OutboundTravel.stub!(:find).with("1").and_return(outbound_travel)
      outbound_travel.should_not_receive(:create_expense_settlement)
      expense_settlement.should_receive(:update_attributes)
      expense_settlement.should_receive(:populate_instance_data)

      post :generate_report, :travel_id => 1

      #TODO: find how to fix this as "_routes" => nil is added to the hash
      #assigns(@expense_report).should == expense_settlement
    end
  end

  describe "handle multiple forex currencies" do
    it "should create all applicable currencies for cash handover properly when forex of multiple currencies are involved" do
      travel_id = '1'
      employee_id = '12321'
      test_forex_currencies = ['EUR', 'GBP']
      expenses = []
      forex_payments = []
      outbound_travel = mock(OutboundTravel, :place => 'UK', :emp_id => employee_id,
                             :departure_date => Date.today - 10, :return_date => Date.today + 5, :id => travel_id)
      OutboundTravel.stub!(:find).with(travel_id).and_return(outbound_travel)
      expected_result_hash = setup_test_data(ExpenseSettlement.new,expenses, forex_payments,employee_id, travel_id, 'UK', outbound_travel,
                                             test_forex_currencies, [],[],[],[])
      Expense.should_receive(:fetch_for_employee_between_dates).with(employee_id, outbound_travel.departure_date - ExpenseSettlementController::EXPENSE_DATES_PADDED_BY,
                                                                     outbound_travel.return_date + ExpenseSettlementController::EXPENSE_DATES_PADDED_BY, []).and_return(expenses)

      ForexPayment.should_receive(:fetch_for).with(employee_id, outbound_travel.departure_date - ExpenseSettlementController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                   outbound_travel.return_date, []).and_return(forex_payments)

      get :load_by_travel, :id => travel_id

      assigns(:expense_report).should == expected_result_hash
      assigns(:all_currencies).should == test_forex_currencies
    end

    xit "should handle settlement properly when forex of multiple currencies are involved" do
      travel_id = '1'
      employee_id = '12321'
      test_forex_currencies = ['EUR', 'GBP']
      expense_amounts = [300, 750]
      expense_amounts_inr = [23032.5, 47437.5]
      forex_amounts = [500, 100]
      forex_amounts_inr = [37309, 6272.5]
      expense_settlement = ExpenseSettlement.new
      expense_settlement[:cash_handover] = 0
      outbound_travel = mock(OutboundTravel, :place => 'UK', :emp_id => employee_id,
                              :departure_date => Date.today - 10, :return_date => Date.today + 5, :id => travel_id,
                              :expense_settlement => expense_settlement)
      OutboundTravel.stub!(:find).with(travel_id).and_return(outbound_travel)
      expenses = []
      forex_payments = []
      expected_result_hash = setup_test_data(expense_settlement,expenses, forex_payments,employee_id, travel_id, 'UK',
                                             outbound_travel,test_forex_currencies,
                                             expense_amounts, expense_amounts_inr, forex_amounts, forex_amounts_inr)

      expense_settlement.should_receive(:update_attributes)
                        .with({:expenses => expense_settlement[:expenses],
                               :forex_payments => expense_settlement[:forex_payments], :cash_handover => 0,
                               :status => "Generated Draft"})
      get :generate_report, :travel_id => travel_id, :forex_payments => expense_settlement[:forex_payments],
          :expenses => expense_settlement[:expenses], :cash_handover => 0

      expense_settlement.instance_variable_get('@net_payable').to_f.should eq -25852
    end
  end

  private
  def setup_test_data(expense_settlement, expenses,forex_payments,employee_id, travel_id, place_of_visit, outbound_travel, currencies,
      expense_amounts, expense_amounts_inr,forex_amounts, forex_amounts_inr)
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
    expense_settlement[:forex_payments] = forex_ids
    ForexPayment.stub!(:find).with(forex_ids).and_return(forex_payments)

    expense_ids = expenses.map{|expense| expense.id.to_s }
    expense_settlement[:expenses] = expense_ids
    Expense.stub!(:find).with(expense_ids).and_return(expenses)

    expected_result_hash = Hash.new
    expected_result_hash["expenses"]=expenses
    expected_result_hash["forex_payments"]=forex_payments
    expected_result_hash["empl_id"]=employee_id
    expected_result_hash["travel_id"]=travel_id
    expected_result_hash
  end
end
