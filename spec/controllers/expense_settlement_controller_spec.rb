require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExpenseSettlementController do

  before(:each) do
    @criteria_mock = mock(Mongoid::Criteria)
    @expense_settlements = [Expense.new]
  end

  describe "load by travel" do

    it "should load the forex and expenses for the given expense id" do
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => Date.today + 5)
      mockProcessedExpenses = [mock("expense", :expenses => [[2]], :forex_payments => [[3]])]
      mockExpenseReportCriteria = mock("Crietria", :to_a => mockProcessedExpenses)
      mockExpenses = mock("expenses")
      mockForex = mock("forex")
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)
      ExpenseReport.should_receive(:where).with({:empl_id=>"1", :processed=>true}).and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:only).with(:expenses, :forex_payments).and_return(mockProcessedExpenses)
      Expense.should_receive(:fetch_for).with(1,outbound_travel.departure_date - ExpenseSettlementController::EXPENSE_DATES_PADDED_BY,
                                               outbound_travel.return_date + ExpenseSettlementController::EXPENSE_DATES_PADDED_BY,
                                               [2]).and_return(mockExpenses)
      ForexPayment.should_receive(:fetch_for).with(1,outbound_travel.departure_date - ExpenseSettlementController::FOREX_PAYMENT_DATES_PADDED_BY,
                                               outbound_travel.return_date + ExpenseSettlementController::FOREX_PAYMENT_DATES_PADDED_BY,
                                               [3]).and_return(mockForex)
      mockExpenseReport = mock("expense_report")
      ExpenseReport.should_receive(:new).with(:expenses => mockExpenses, 
                                              :forex_payments => mockForex, :empl_id => 1, :travel_id => "123").and_return(mockExpenseReport)
      get :load_by_travel, :id => 123
      assigns(:expense_report).should == mockExpenseReport
    end

    it "should use the date for forex and expenses if they are passed as params" do
      outbound_travel = mock("outbound_travel", :id => 123, :emp_id => 1, :departure_date => Date.today - 10, :return_date => Date.today + 5)
      mockProcessedExpenses = [mock("expense", :expenses => [[2]], :forex_payments => [[3]])]
      mockExpenseReportCriteria = mock("Crietria", :to_a => mockProcessedExpenses)
      mockExpenses = mock("expenses")
      mockForex = mock("forex")
      forex_from, forex_to, expense_to, expense_from = Date.today, Date.today + 1, Date.today + 2, Date.today + 3
      OutboundTravel.should_receive(:find).with("123").and_return(outbound_travel)
      ExpenseReport.should_receive(:where).with({:empl_id=>"1", :processed=>true}).and_return(mockExpenseReportCriteria)
      mockExpenseReportCriteria.should_receive(:only).with(:expenses, :forex_payments).and_return(mockProcessedExpenses)
      Expense.should_receive(:fetch_for).with(1,expense_from,expense_to,[2]).and_return(mockExpenses)
      ForexPayment.should_receive(:fetch_for).with(1,forex_from,forex_to,[3]).and_return(mockForex)
      mockExpenseReport = mock("expense_report")
      ExpenseReport.should_receive(:new).with(:expenses => mockExpenses, 
                                              :forex_payments => mockForex, :empl_id => 1, :travel_id => "123").and_return(mockExpenseReport)
      get :load_by_travel, :id => 123, :forex_from => forex_from, :forex_to => forex_to, :expense_from => expense_from, :expense_to => expense_to
    end
  end

  describe "GET 'fetch'" do

    it "fetches expenses from db for emplid" do
      ExpenseReport.stub!(:where).with({:empl_id => "1"}).and_return(@criteria_mock)
      @criteria_mock.should_receive(:to_a).and_return(@expense_settlements)
      get :index, :id => 1
      assigns(:expense_settlements).should == @expense_settlements
      response.should be_success
    end

  end

  describe "POST 'notify'" do
    it "should send notification to employee upon expense settlement computation" do
      expense_report_id = '1'
      employee_id = 1
      expense_report = mock("expense_report", :empl_id => employee_id, :populate_instance_data => "nothing")
      mock_profile = mock(Profile)
      ExpenseReport.should_receive(:find).with(expense_report_id).and_return(expense_report)
      Profile.should_receive(:find_all_by_employee_id).with(employee_id).and_return(mock_profile)
      expense_settlement_page = 'expense_report_settlement'
      request.env['HTTP_REFERER'] = expense_settlement_page
      EmployeeMailer.stub(:expense_settlement).and_return(mock('mailer', :deliver => 'nothing'))
      post :notify, :id => expense_report_id
      response.should redirect_to expense_settlement_page
    end
  end
end
