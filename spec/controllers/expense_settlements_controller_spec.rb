require 'spec_helper'

describe ExpenseSettlementsController do
  describe "load by travel" do
    it "should load the forex and expenses for the given expense id" do
      outbound_travel = Factory(:outbound_travel, :departure_date => Date.today - 10.days, :return_date => Date.today + 5.days)
      expenses = [Factory(:expense)]
      forex_payments = [Factory(:forex_payment)]
      processed_expenses = [Factory(:expense_settlement, :expenses => expenses.collect(&:id), :forex_payments => forex_payments.collect(&:id))]

      ExpenseSettlement.should_receive(:load_processed_for).with(outbound_travel.emp_id).and_return(processed_expenses)
      Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id,
                                                              outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                              outbound_travel.return_date + ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                              expenses.collect(&:id)).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id,
                                            outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                            outbound_travel.return_date,
                                            forex_payments.collect(&:id)).and_return(forex_payments)

      get :load_by_travel, :id => outbound_travel.id.to_s

      assigned_expense_report = assigns(:expense_report)
      assigned_expense_report.should_not be_nil
      assigned_expense_report.outbound_travel_id.should_not be_nil
      assigned_expense_report.expenses.should == expenses.collect(&:id)
      assigned_expense_report.forex_payments.should == forex_payments.collect(&:id)

      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
    end

    it "should show forex and travel properly for the given expense id even if return travel date is nil" do
      outbound_travel = Factory(:outbound_travel, :departure_date => Date.today - 10.days, :return_date => nil)
      expenses = [Factory(:expense)]
      forex_payments = [Factory(:forex_payment)]
      Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                                     nil, []).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                   nil, []).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:empl_id => outbound_travel.emp_id,
                                                          :outbound_travel_id => outbound_travel.id.to_s,
                                                          :expenses => expenses.collect(&:id),
                                                          :forex_payments => forex_payments.collect(&:id),
                                                          :cash_handovers => [])

      get :load_by_travel, :id => outbound_travel.id.to_s

      assigns(:expense_report).should have_same_attributes_as(expected_expense_settlement)
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
      assigns(:expenses_to_date).should be_nil
      assigns(:forex_to_date).should be_nil
    end

    it "should use the date for forex and expenses if they are passed as params" do
      outbound_travel = Factory(:outbound_travel, :departure_date => Date.today - 10.days, :return_date => Date.today + 5.days)
      expenses = [Factory(:expense)]
      forex_payments = [Factory(:forex_payment)]
      processed_expenses = [Factory(:expense_settlement, :expenses => expenses.collect(&:id), :forex_payments => forex_payments.collect(&:id))]
      forex_from, forex_to, expense_to, expense_from = Date.today, Date.today + 1.days, Date.today + 2.days, Date.today + 3.days

      ExpenseSettlement.should_receive(:load_processed_for).with(outbound_travel.emp_id).and_return(processed_expenses)
      Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id, expense_from, expense_to, expenses.collect(&:id)).and_return(expenses)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, forex_from, forex_to, forex_payments.collect(&:id)).and_return(forex_payments)

      expected_expense_settlement = ExpenseSettlement.new(:empl_id => outbound_travel.emp_id,
                                                          :outbound_travel_id => outbound_travel.id.to_s,
                                                          :expenses => expenses.collect(&:id),
                                                          :forex_payments => forex_payments.collect(&:id),
                                                          :cash_handovers => [])

      get :load_by_travel, :id => outbound_travel.id.to_s, :forex_from => forex_from, :forex_to => forex_to, :expense_from => expense_from, :expense_to => expense_to

      assigns(:expense_report).should have_same_attributes_as(expected_expense_settlement)
      assigns(:expenses).should == expenses
      assigns(:forex_payments).should == forex_payments
    end
  end

  describe "GET 'index'" do
    it "index expenses from db for emplid" do
      empl_id = 123
      expense_settlements = [Factory(:expense_settlement, :empl_id => empl_id),
                             Factory(:expense_settlement, :empl_id => empl_id),
                             Factory(:expense_settlement, :empl_id => empl_id)]

      ExpenseSettlement.stub_chain(:where, :page, :per).and_return(expense_settlements)

      get :index, :empl_id => empl_id

      response.should be_success
      assigns(:expense_settlements).should == expense_settlements
    end
  end

  employee_name = 'John Smith'
  describe "POST 'notify'" do
    it "should send notification to employee upon expense settlement computation" do
      expense_report_id = '1'
      employee_id = 1
      mock_profile = mock('Profile', :common_name => employee_name)
      expense_report = Factory(:expense_settlement, :empl_id => employee_id)
      ExpenseSettlement.should_receive(:find).with(expense_report_id).and_return(expense_report)
      expense_report.should_receive(:notify_employee)
      expense_report.should_receive(:profile).and_return(mock_profile)

      post :notify, :id => expense_report_id

      response.should redirect_to(:action => :index, :anchor => 'expense_settlements', :empl_id => employee_id)
      flash[:success].should == "Expense settlement e-mail successfully sent to 'John Smith'"
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
      expense_settlement = ExpenseSettlement.new(:empl_id => empl_id, :expenses => [expense.id], :forex_payments => [forex_payment.id],
                                                 :status => ExpenseSettlement::GENERATED_DRAFT,
                                                  :expense_from => DateHelper::date_fmt(expense_from),
                                                  :expense_to => DateHelper::date_fmt(expense_to),
                                                  :forex_from => DateHelper::date_fmt(forex_from),
                                                  :forex_to => DateHelper::date_fmt(forex_to),
                                                  :cash_handovers =>
                                                    [CashHandover.new(:amount => 100, :currency => currency,
                                                                      :conversion_rate => 72.50)])
      outbound_travel.save!
      expense_settlement.cash_handovers.map(&:save!)
      expense_settlement.outbound_travel_id = outbound_travel.id
      expense_settlement.save!
      OutboundTravel.should_receive(:find).with(outbound_travel.id).and_return(outbound_travel)
      ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, forex_from, forex_to, anything)
                      .and_return([forex_payment])
      ForexPayment.should_receive(:find).with([forex_payment.id]).and_return([forex_payment])
      ForexPayment.should_receive(:all).and_return([forex_payment])
      Expense.should_receive(:fetch_for_employee_between_dates)
                      .with(outbound_travel.emp_id, expense_from, expense_to, anything)
                      .and_return([expense])
      Expense.should_receive(:find).with([expense.id]).and_return([expense])
      stub_expense_settlement = mock('Object')
      ExpenseSettlement.should_receive(:includes).with(:cash_handovers, :outbound_travel).and_return(stub_expense_settlement)
      stub_expense_settlement.should_receive(:find).with(expense_settlement.id.to_s).and_return(expense_settlement)

      get :edit, :id => expense_settlement.id.to_s

      assigns(:expense_report).should have_same_attributes_as(expense_settlement)
      assigns(:has_cash_handovers).should be true
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
      outbound_travel.should_receive(:create_expense_settlement).never
      expense_settlement.should_receive(:update_attributes)
      expense_settlement.should_receive(:populate_instance_data)

      post :generate_report, :travel_id => 1

      assigns(@expense_report).should == expense_settlement
    end
  end

  it "should create all applicable currencies for cash handover properly when forex of multiple currencies are involved" do
    outbound_travel = Factory(:outbound_travel, :place => 'UK',
                              :departure_date => Date.today - 10.days, :return_date => Date.today + 5.days)
    travel_id = outbound_travel.id
    test_forex_currencies = ['EUR', 'GBP']
    expenses = [Factory(:expense, :original_currency => 'EUR', :original_cost => 100, :cost_in_home_currency => 7200)]
    forex_payments = []
    forex_ids = []
    test_forex_currencies.each_with_index do |forex_currency, index|
      forex_payment = Factory(:forex_payment, :currency => test_forex_currencies[index])
      forex_ids << forex_payment.id
      forex_payments << forex_payment
    end

    Expense.should_receive(:fetch_for_employee_between_dates).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY,
                                                                   outbound_travel.return_date + ExpenseSettlementsController::EXPENSE_DATES_PADDED_BY, []).and_return(expenses)

    ForexPayment.should_receive(:fetch_for).with(outbound_travel.emp_id, outbound_travel.departure_date - ExpenseSettlementsController::FOREX_PAYMENT_DATES_PADDED_BY,
                                                 outbound_travel.return_date, []).and_return(forex_payments)

    expected_expense_settlement = ExpenseSettlement.new(:outbound_travel_id => outbound_travel.id, :empl_id => outbound_travel.emp_id,
                                                        :expenses => [expenses[0].id],
                                                        :forex_payments => forex_ids,
                                                        :cash_handovers => [CashHandover.new])

    ForexPayment.should_receive(:get_json_to_populate).with('currency').and_return({'currency' => test_forex_currencies})

    get :load_by_travel, :id => outbound_travel.id.to_s

    assigns(:expense_report).should have_same_attributes_as(expected_expense_settlement)
    assigns(:applicable_currencies).should == test_forex_currencies
    assigns(:expenses).should == expenses
    assigns(:payment_modes).should == [CashHandover::CASH, CashHandover::CREDIT_CARD]
    assigns(:has_cash_handovers).should be false
    assigns(:forex_payments).should == forex_payments
  end

  it "should set required model objects properly for view when forex of multiple currencies are involved" do
    currency = 'EUR'
    outbound_travel = Factory(:outbound_travel, :place => 'UK',
                           :departure_date => Date.today - 10.days, :return_date => Date.today + 5.days)
    test_forex_currencies = [currency, 'GBP']

    cash_handovers = [CashHandover.new(:amount => 100, :currency => currency, :conversion_rate => 72.30),
                      CashHandover.new(:amount => 150, :currency => 'GBP', :conversion_rate => 52.31)]
    handovers = {}
    values_hash = {}

    cash_handovers.each_with_index { |item, index| handovers[index.to_s] = item.declared_attributes}

    forex_payments = [Factory(:forex_payment, :currency => currency, :inr => 7200, :amount => 200)]

    expenses = [Factory(:expense, :expense_rpt_id => 1, :original_currency => currency, :original_cost => 100)]

    expense_settlement = ExpenseSettlement.new(:id => 1, :forex_payments => forex_payments.collect(&:id),
                              :expenses => expenses.collect(&:id), :empl_id => outbound_travel.emp_id, :outbound_travel_id => outbound_travel.id.to_s,
                              :cash_handovers => cash_handovers)
    expense_settlement.stub!(:get_receivable_amount).and_return(13732.5)

    OutboundTravel.stub!(:find).with(outbound_travel.id.to_s).and_return(outbound_travel)
    outbound_travel.should_receive(:find_or_initialize_expense_settlement).and_return(expense_settlement)

    post :generate_report, {:expense_settlement => {:id => expense_settlement.id.to_s, :empl_id => outbound_travel.emp_id.to_s,
                                                   :outbound_travel_id => outbound_travel.id.to_s, :emp_name => employee_name,
                                                   :cash_handovers_attributes => handovers},
                            :forex_payments => forex_payments.collect(&:id), :expenses => expenses.collect(&:id)
    }

    assigns(:expense_report).should have_same_attributes_as(expense_settlement)
    assigns(:expense_report).instance_variable_get('@net_payable').should == 13732.5
  end

  private
  def setup_test_data(expenses, forex_payments, employee_id, travel_id, place_of_visit, outbound_travel, currencies,
      expense_amounts, expense_amounts_inr, forex_amounts, forex_amounts_inr, cash_handovers)
    currencies.each_with_index do |currency, index|
      expenses << Factory(:expense, :empl_id => employee_id, :original_currency => currency, :place => place_of_visit,
                       :cost_in_home_currency => expense_amounts_inr[index], :expense_rpt_id => index,
                       :original_cost => expense_amounts[index])

      forex_payments << Factory(:forex_payment, :emp_id => employee_id, :currency => currency,
                             :place => place_of_visit, :amount => forex_amounts[index], :inr => forex_amounts_inr[index])
    end

    forex_ids = forex_payments.collect(&:id)
    ForexPayment.stub!(:find).with(forex_ids).and_return(forex_payments)

    expense_ids = expenses.collect(&:id)
    Expense.stub!(:find).with(expense_ids).and_return(expenses)

    ExpenseSettlement.new(:empl_id => employee_id, :outbound_travel_id => travel_id, :expenses => expense_ids,
                                                          :forex_payments => forex_ids,
                                                          :cash_handovers => cash_handovers)
  end
end
