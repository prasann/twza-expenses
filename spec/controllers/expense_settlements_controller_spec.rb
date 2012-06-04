require 'spec_helper'

describe ExpenseSettlementsController do
  describe "load_by_travel" do
    it "should load the forex and expenses for the given expense id" do
      outbound_travel = FactoryGirl.create(:outbound_travel, :departure_date => Date.today - 10.days, :return_date => Date.today + 5.days)
      expenses = [FactoryGirl.create(:expense)]
      forex_payments = [FactoryGirl.create(:forex_payment)]
      processed_expenses = [FactoryGirl.create(:expense_settlement, :expenses => expenses.collect{|expense| {'expense_id' => expense.id.to_s}}, :forex_payments => forex_payments.collect(&:id))]

      ExpenseSettlement.should_receive(:load_processed_for).with(outbound_travel.emp_id).and_return(processed_expenses)
      Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id,
                                                              outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                              outbound_travel.return_date + ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                              expenses.collect{|expense| expense.id.to_s}).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id,
                                            outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                            outbound_travel.return_date,
                                            forex_payments.collect(&:id)).and_return(forex_payments)

      get :load_by_travel, :id => outbound_travel.id.to_s

      assigned_expense_settlement = assigns(:expense_settlement)
      assigned_expense_settlement.should_not be_nil
      assigned_expense_settlement.expenses.should == expenses.collect(&:id)
      assigned_expense_settlement.forex_payments.should == forex_payments.collect(&:id)

      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
    end

    it "should show forex and travel properly for the given expense id even if return travel date is nil" do
      outbound_travel = FactoryGirl.create(:outbound_travel, :departure_date => Date.today - 10.days, :return_date => nil)
      expenses = [FactoryGirl.create(:expense)]
      forex_payments = [FactoryGirl.create(:forex_payment)]
      Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                                     nil, []).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                   nil, []).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:empl_id => outbound_travel.emp_id,
                                                          :expenses => expenses.collect(&:id),
                                                          :forex_payments => forex_payments.collect(&:id),
                                                          :cash_handovers => [])

      get :load_by_travel, :id => outbound_travel.id.to_s

      assigns(:expense_settlement).should have_same_attributes_as(expected_expense_settlement)
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
      assigns(:expenses_to_date).should be_nil
      assigns(:forex_to_date).should be_nil
    end

    it "should use the date for forex and expenses if they are passed as params" do
      outbound_travel = FactoryGirl.create(:outbound_travel, :departure_date => Date.today - 10.days, :return_date => Date.today + 5.days)
      expenses = [FactoryGirl.create(:expense)]
      forex_payments = [FactoryGirl.create(:forex_payment)]
      processed_expenses = [FactoryGirl.create(:expense_settlement, :expenses => expenses.collect{|expense| {'expense_id' => expense.id.to_s}}, :forex_payments => forex_payments.collect(&:id))]
      forex_from, forex_to, expense_to, expense_from = Date.today, Date.today + 1.days, Date.today + 2.days, Date.today + 3.days

      ExpenseSettlement.should_receive(:load_processed_for).with(outbound_travel.emp_id).and_return(processed_expenses)
      Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id, expense_from, expense_to, expenses.collect{|expense| expense.id.to_s}).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, forex_from, forex_to, forex_payments.collect(&:id)).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:empl_id => outbound_travel.emp_id,
                                                          :expenses => expenses.collect(&:id),
                                                          :forex_payments => forex_payments.collect(&:id),
                                                          :cash_handovers => [])

      get :load_by_travel, :id => outbound_travel.id.to_s, :forex_from => forex_from, :forex_to => forex_to, :expense_from => expense_from, :expense_to => expense_to

      assigns(:expense_settlement).should have_same_attributes_as(expected_expense_settlement)
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
    end
  end

  describe "index" do
    it "index expenses from db for emplid" do
      empl_id = 123
      expense_settlements = [FactoryGirl.create(:expense_settlement, :empl_id => empl_id),
                             FactoryGirl.create(:expense_settlement, :empl_id => empl_id),
                             FactoryGirl.create(:expense_settlement, :empl_id => empl_id)]

      ExpenseSettlement.stub_chain(:where, :page, :per).and_return(expense_settlements)

      get :index, :empl_id => empl_id

      response.should be_success
      assigns(:expense_settlements).should == expense_settlements
    end
  end

  employee_name = 'John Smith'
  describe "notify" do
    it "should send notification to employee upon expense settlement computation" do
      expense_report_id = '1'
      employee_id = 1
      employee_detail = EmployeeDetail.new(:emp_name => employee_name)
      expense_settlement = FactoryGirl.create(:expense_settlement, :empl_id => employee_id.to_s)
      ExpenseSettlement.should_receive(:find).with(expense_report_id).and_return(expense_settlement)
      expense_settlement.should_receive(:notify_employee)
      expense_settlement.should_receive(:employee_detail).and_return(employee_detail)

      post :notify, :id => expense_report_id

      response.should redirect_to(expense_settlements_path)
      flash[:success].should == "Expense settlement e-mail successfully sent to 'John Smith'"
    end
  end

  describe "edit expense settlement" do
    it "should allow to edit an already created expense settlement" do
      empl_id = 1
      expense_from = Date.today - 5.days
      expense_to = Date.today - 3.days
      forex_from = Date.today - 6.days
      forex_to = Date.today - 4.days
      outbound_travel = FactoryGirl.create(:outbound_travel, :emp_id => empl_id)
      forex_payment = FactoryGirl.create(:forex_payment)
      expense = FactoryGirl.create(:expense)
      expense_settlement = FactoryGirl.create(:expense_settlement, :empl_id => empl_id.to_s, 
                                              :expenses => [expense.id],
                                              :forex_payments => [forex_payment.id],
                                              :status => ExpenseSettlement::GENERATED_DRAFT,
                                              :expense_from => expense_from,
                                              :expense_to => expense_to,
                                              :forex_from => forex_from,
                                              :forex_to => forex_to,
                                              :cash_handovers =>
                                                    [CashHandover.new(:amount => 100, :currency => forex_payment.currency,
                                                                      :conversion_rate => 72.50)])
      expense_settlement.cash_handovers.map(&:save!)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, forex_from, forex_to, anything)
                      .and_return([forex_payment])
      ForexPayment.should_receive(:find).with([forex_payment.id]).and_return([forex_payment])
      ForexPayment.should_receive(:all).and_return([forex_payment])
      Expense.should_receive(:fetch_for_employee_between_dates)
                      .with(outbound_travel.emp_id, expense_from, expense_to, anything)
                      .and_return([expense])
      Expense.should_receive(:find).with([expense.id]).and_return([expense])
      stub_expense_settlement = mock('Object')
      ExpenseSettlement.should_receive(:includes).with(:cash_handovers).and_return(stub_expense_settlement)
      stub_expense_settlement.should_receive(:find).with(expense_settlement.id.to_s).and_return(expense_settlement)

      get :edit, :id => expense_settlement.id.to_s

      assigns(:expense_settlement).should have_same_attributes_as(expense_settlement)
      assigns(:has_cash_handovers).should be_true
      assigns(:applicable_currencies).should == [forex_payment.currency]
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
      empl_id = "123"
      outbound_travel = FactoryGirl.create(:outbound_travel)
      user_name = 'prasann'
      expected_expense_settlement = FactoryGirl.create(:expense_settlement, :empl_id => empl_id,
                                              :emp_name => 'name', 
                                              :forex_from => "27-Nov-2011", :forex_to => "17-Dec-2011",
                                             :expense_from => "07-Dec-2011", :expense_to => "22-Dec-2011",:created_by => user_name)

      user = FactoryGirl.create(:user, :user_name => user_name)
      session[:user_id] = user.id
      expect {
        post :generate_report, :expense_settlement => { :outbound_travel_id => outbound_travel.id,
                                                        :empl_id => empl_id, :emp_name => 'name' },
                               :forex_from => "27-Nov-2011", :forex_to => "17-Dec-2011",
                               :expense_from => "07-Dec-2011", :expense_to => "22-Dec-2011"
      }.to change(ExpenseSettlement, :count).by(1)

      assigns(:expense_settlement).should_not be_nil
      assigns(:expense_settlement).should have_same_attributes_as(expected_expense_settlement)
    end

    it "should update expense report if it already exists in the travel" do
      empl_id = "123"
      user_name = 'prasann'
      outbound_travel = FactoryGirl.create(:outbound_travel)
      expected_expense_settlement = FactoryGirl.create(:expense_settlement, :empl_id => empl_id,
                                              :emp_name => 'name', 
                                              :forex_from => "27-Nov-2011", :forex_to => "17-Dec-2011",
                                             :expense_from => "07-Dec-2011", :expense_to => "22-Dec-2011",:created_by => user_name)
      user = FactoryGirl.create(:user, :user_name => user_name)
      session[:user_id] = user.id

      expect {
        post :generate_report, :expense_settlement => {:id => expected_expense_settlement.id.to_s, 
                               :outbound_travel_id => outbound_travel.id,
                               :empl_id => empl_id, :emp_name => 'name' },
                               :forex_from => "27-Nov-2011", :forex_to => "17-Dec-2011",
                               :expense_from => "07-Dec-2011", :expense_to => "22-Dec-2011"
      }.to_not change(ExpenseSettlement, :count)

      assigns(:expense_settlement).should_not be_nil
      assigns(:expense_settlement).should have_same_attributes_as(expected_expense_settlement)
    end
  end

  it "should create all applicable currencies for cash handover properly when forex of multiple currencies are involved" do
    outbound_travel = FactoryGirl.create(:outbound_travel, :departure_date => Date.today - 10.days, :return_date => Date.today + 5.days)
    travel_id = outbound_travel.id
    test_forex_currencies = ['EUR', 'GBP']
    expenses = [FactoryGirl.create(:expense)]
    forex_payments = []
    forex_ids = []
    test_forex_currencies.each_with_index do |forex_currency, index|
      forex_payment = FactoryGirl.create(:forex_payment, :currency => test_forex_currencies[index])
      forex_ids << forex_payment.id
      forex_payments << forex_payment
    end

    Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                                   outbound_travel.return_date + ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY, []).and_return(expenses)

    ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                 outbound_travel.return_date, []).and_return(forex_payments)

    expected_expense_settlement = ExpenseSettlement.new(:empl_id => outbound_travel.emp_id,
                                                        :expenses => expenses.collect(&:id),
                                                        :forex_payments => forex_ids,
                                                        :cash_handovers => [CashHandover.new])

    ForexPayment.should_receive(:get_json_to_populate).with('currency').and_return({'currency' => test_forex_currencies})

    get :load_by_travel, :id => outbound_travel.id.to_s

    assigns(:expense_settlement).should have_same_attributes_as(expected_expense_settlement)
    assigns(:applicable_currencies).should == test_forex_currencies
    assigns(:expenses).should == expenses
    assigns(:payment_modes).should == [CashHandover::CASH, CashHandover::CREDIT_CARD]
    assigns(:has_cash_handovers).should be_false
    assigns(:forex_payments).should == forex_payments
  end

  it "should set required model objects properly for view when forex of multiple currencies are involved" do
    currency = 'EUR'
    outbound_travel = FactoryGirl.create(:outbound_travel)
    test_forex_currencies = [currency, 'GBP']

    cash_handovers = [CashHandover.new(:amount => 100, :currency => currency, :conversion_rate => 72.30),
                      CashHandover.new(:amount => 150, :currency => 'GBP', :conversion_rate => 52.31)]
    handovers = {}
    values_hash = {}

    cash_handovers.each_with_index { |item, index| handovers[index.to_s] = item.declared_attributes}

    forex_payments = [FactoryGirl.create(:forex_payment, :currency => currency)]

    expenses = [FactoryGirl.create(:expense)]

    expense_settlement = FactoryGirl.create(:expense_settlement, :forex_payments => forex_payments.collect(&:id),
                              :expenses => expenses.collect(&:id), 
                              :empl_id => outbound_travel.emp_id, :emp_name => employee_name,
                              :cash_handovers => cash_handovers, :created_by => 'prasann')
    expense_settlement.should_receive(:get_receivable_amount).and_return(13732.5)
    user = FactoryGirl.create(:user)
    session[:user_id] = user.id
    ExpenseSettlement.should_receive(:find_or_initialize).and_return(expense_settlement)
    OutboundTravel.should_receive(:set_as_processed).with(outbound_travel.id.to_s)

    post :generate_report, {:expense_settlement => {:id => expense_settlement.id.to_s, :empl_id => outbound_travel.emp_id.to_s,
                                                   :outbound_travel_id => outbound_travel.id.to_s, :emp_name => employee_name,
                                                   :cash_handovers_attributes => handovers},
                            :forex_payments => forex_payments.collect(&:id), :expenses => expenses.collect(&:id),
                            :forex_from => "27-Nov-2011", :forex_to => "17-Dec-2011",
                            :expense_from => "07-Dec-2011", :expense_to => "22-Dec-2011"
    }
    assigns(:expense_settlement).should have_same_attributes_as(expense_settlement)
    assigns(:expense_settlement).instance_variable_get('@net_payable').should == 13732.5
  end

  it "should delete a cash_handover model" do
    cash_handover = FactoryGirl.create(:cash_handover, :amount => 100, :currency => 'USD', :conversion_rate => 72.30)
    post :delete_cash_handover, {:id => cash_handover.id}
    lambda {CashHandover.find(cash_handover.id) }.should raise_exception
  end

  it "should delete expense and uploaded expense and set upon flash success" do
    expenses = [FactoryGirl.create(:expense, :file_name => "file_1"),FactoryGirl.create(:expense, :file_name => "file_2")]
    uploaded_expenses = [FactoryGirl.create(:uploaded_expense, :file_name => "file_1"),FactoryGirl.create(:uploaded_expense, :file_name => "file_2")]
    post :delete_expense, {:file_name => "file_1"}
    Expense.all.should == [expenses[1]]
    UploadedExpense.all.should == [uploaded_expenses[1]]
    flash[:success].should == "File: 'file_1' has been deleted successfully"
  end

  it "should not throw exception when a unknown file is been asked for deletion" do
    expenses = [FactoryGirl.create(:expense, :file_name => "file_1"),FactoryGirl.create(:expense, :file_name => "file_2")]
    uploaded_expenses = [FactoryGirl.create(:uploaded_expense, :file_name => "file_1"),FactoryGirl.create(:uploaded_expense, :file_name => "file_2")]
    expect {
      post :delete_expense, {:file_name => "unknown_file"}
      }.to_not change(Expense, :count)
    flash[:error].should == "No records deleted"
  end
end
