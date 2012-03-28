require 'spec_helper'

describe 'expense_report' do
  it "should consolidate expenses by rpt and currency considering conversion rate" do
    persisted_expenses = [
                Factory(:expense, :expense_rpt_id => 123, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200')),
                Factory(:expense, :expense_rpt_id => 122, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                Factory(:expense, :expense_rpt_id => 121, :original_currency => 'INR', :original_cost => BigDecimal.new('1000'),:cost_in_home_currency => BigDecimal.new('4000')),
                Factory(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                Factory(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200'))
              ]
    forex_payments = [Factory(:forex_payment, :currency => 'EUR', :inr => 100, :amount => 100)]
    exp_rpt = Factory(:expense_settlement, :expenses => persisted_expenses.collect(&:id))
    expected_hash_1 = {'report_id' => 123, 'currency' => 'EUR', 'amount' => 200, 'conversion_rate' => 1, 'local_currency_amount' => 200}
    expected_hash_2 = {'report_id' => 122, 'currency' => 'EUR', 'amount' => 100, 'conversion_rate' => 1, 'local_currency_amount' => 100}
    expected_hash_3 = {'report_id' => 121, 'currency' => 'EUR', 'amount' => 300, 'conversion_rate' => 1, 'local_currency_amount' => 300}
    expected_hash_4 = {'report_id' => 121, 'currency' => 'INR', 'amount' => 1000, 'conversion_rate' => 4, 'local_currency_amount' => 4000}

    exp_rpt.populate_instance_data

    actual_consolidated = exp_rpt.get_consolidated_expenses
    actual_consolidated.count.should == 4
    actual_consolidated.should include(expected_hash_1)
    actual_consolidated.should include(expected_hash_2)
    actual_consolidated.should include(expected_hash_3)
    actual_consolidated.should include(expected_hash_4)
  end

  it "should consolidate expenses by rpt and currency considering conversion rate from sharon sheet if no forex is available" do
    persisted_expenses = [
                Factory(:expense, :expense_rpt_id => 123, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200')),
                Factory(:expense, :expense_rpt_id => 122, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                Factory(:expense, :expense_rpt_id => 121, :original_currency => 'INR', :original_cost => BigDecimal.new('1000'),:cost_in_home_currency => BigDecimal.new('4000')),
                Factory(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('100'), :cost_in_home_currency => BigDecimal.new('100')),
                Factory(:expense, :expense_rpt_id => 121, :original_currency => 'EUR', :original_cost => BigDecimal.new('200'), :cost_in_home_currency => BigDecimal.new('200'))
              ]

    exp_rpt = Factory(:expense_settlement, :expenses => persisted_expenses.collect(&:id))
    expected_hash_1 = {'report_id' => 123, 'currency' => 'EUR', 'amount' => 200, 'conversion_rate' => 1, 'local_currency_amount' => 200}
    expected_hash_2 = {'report_id' => 122, 'currency' => 'EUR', 'amount' => 100, 'conversion_rate' => 1, 'local_currency_amount' => 100}
    expected_hash_3 = {'report_id' => 121, 'currency' => 'EUR', 'amount' => 300, 'conversion_rate' => 1, 'local_currency_amount' => 300}
    expected_hash_4 = {'report_id' => 121, 'currency' => 'INR', 'amount' => 1000, 'conversion_rate' => 4, 'local_currency_amount' => 4000}

    exp_rpt.populate_instance_data

    actual_consolidated = exp_rpt.get_consolidated_expenses

    actual_consolidated.count.should == 4
    actual_consolidated.should include(expected_hash_1)
    actual_consolidated.should include(expected_hash_2)
    actual_consolidated.should include(expected_hash_3)
    actual_consolidated.should include(expected_hash_4)
  end

  it "should provide average forex rate for each currency" do
    forex_payments = [Factory(:forex_payment, :currency => 'EUR', :inr => 2000, :amount => 100),
            Factory(:forex_payment, :currency => 'EUR', :inr => 1800, :amount => 100),
            Factory(:forex_payment, :currency => 'EUR', :inr => 950, :amount => 50),
            Factory(:forex_payment, :currency => 'USD', :inr => 1000, :amount => 100),
            Factory(:forex_payment, :currency => 'USD', :inr => 810, :amount => 90)]

    # ForexPayment.stub!(:find).and_return(forex_payments)
    exp_rpt = Factory(:expense_settlement, :forex_payments => forex_payments.collect(&:id))
    exp_rpt.populate_forex_payments
    actual_conv_rates = exp_rpt.get_conversion_rates_for_currency
    actual_conv_rates.values.count == 2
    ((actual_conv_rates["USD"]*100).round.to_f/100).should == (((1000+810).to_f/(100+90))*100).round.to_f/100
    ((actual_conv_rates["EUR"]*100).round.to_f/100).should == (((2000+1800+950).to_f/(100+100+50))*100).round.to_f/100
  end

  it "should return employee id appended with e-mail domain as employee e-mail ID if email_id is not available" do
    profile = mock('Profile', :email_id => '')
    expense_report = Factory.build(:expense_settlement, :empl_id => 13552)
    expense_report.stub!(:profile).and_return(profile)
    email = expense_report.employee_email
    email.should == '13552' + ::Rails.application.config.email_domain
  end

  it "should return e-mail ID as employee email if it is available" do
    profile = mock('Profile', :email_id => 'johns')
    expense_report = Factory.build(:expense_settlement)
    expense_report.stub!(:profile).and_return(profile)
    email = expense_report.employee_email
    email.should == 'johns' + ::Rails.application.config.email_domain
  end

  it "should compute settlement properly when forex of multiple currencies are involved" do
    employee_id = '12321'
    test_forex_currencies = ['EUR', 'GBP']
    expense_amounts = [BigDecimal.new('300'), BigDecimal.new('750')]
    expense_amounts_inr = [BigDecimal.new('23032.5'), BigDecimal.new('47437.5')]
    forex_amounts = [500, 1000]
    forex_amounts_inr = [37309, 62728.5]
    outbound_travel = Factory(:outbound_travel, :place => 'UK', :emp_id => employee_id,
                              :departure_date => Date.today - 10, :return_date => Date.today + 5)
    travel_id = outbound_travel.id
    expenses = []
    forex_payments = []
    cash_handovers = [Factory(:cash_handover, :amount => 100, :currency => 'EUR', :conversion_rate => 74.62),
                      Factory(:cash_handover, :amount => 150, :currency => 'GBP', :conversion_rate => 62.73)]

    test_forex_currencies.each_with_index do |currency, index|
      expenses << Factory(:expense, :empl_id => employee_id, :original_currency => currency,
                          :cost_in_home_currency => expense_amounts_inr[index], :expense_rpt_id => index,
                          :original_cost => expense_amounts[index])

      forex_payments << Factory(:forex_payment, :emp_id => employee_id, :currency => currency,
                                :place => 'UK', :amount => forex_amounts[index], :inr => forex_amounts_inr[index])
    end

    expense_settlement = Factory(:expense_settlement, :empl_id => employee_id,
                                 :expenses => expenses.collect(&:id),
                                 :forex_payments => forex_payments.collect(&:id),
                                 :cash_handovers => cash_handovers)

    expense_settlement.populate_instance_data
    expense_settlement.instance_variable_get('@net_payable').should eq 13732.5
  end

  it "should load cash handovers and expenses eagerly on call of load with deps" do
    settlement = Factory(:expense_settlement)
    mock_criteria = mock('Object')
    ExpenseSettlement.should_receive(:includes).with(:cash_handovers,
                                                     :outbound_travel).and_return(mock_criteria)
    mock_criteria.should_receive(:find).with(settlement.id).and_return(settlement)
    settlement.should_receive(:populate_instance_data)

    ExpenseSettlement.load_with_deps(settlement.id)
  end
end
