require 'spec_helper'

describe 'expense_report' do

	it "should consolidate expenses by rpt and currency considering conversion rate" do
		persisted_expenses  = [
								Expense.new(expense_rpt_id: '123',original_currency: 'EUR', original_cost:'200', cost_in_home_currency:'200'),
								Expense.new(expense_rpt_id: '122',original_currency: 'EUR', original_cost:'100', cost_in_home_currency:'100'),
								Expense.new(expense_rpt_id: '121',original_currency: 'INR', original_cost:'1000', cost_in_home_currency:'4000'),
								Expense.new(expense_rpt_id: '121',original_currency: 'EUR', original_cost:'100', cost_in_home_currency:'100'),
								Expense.new(expense_rpt_id: '121',original_currency: 'EUR', original_cost:'200', cost_in_home_currency:'200')
							 ]
		forex_payments = [ForexPayment.new(:currency => 'EUR', :inr => 100, :amount => 100)] 
		Expense.stub(:find).and_return(persisted_expenses)
		ForexPayment.stub(:find).and_return(forex_payments)
		exp_rpt = ExpenseSettlement.new(:expenses => ['somehashes'])
		expected_hash_1 = {'report_id' => '123', 'currency' => 'EUR', 'amount' => 200, 'conversion_rate' => 1, 'local_currency_amount' => 200} 
		expected_hash_2 = {'report_id' => '122', 'currency' => 'EUR', 'amount' => 100, 'conversion_rate' => 1, 'local_currency_amount' => 100} 
		expected_hash_3 = {'report_id' => '121', 'currency' => 'EUR', 'amount' => 300, 'conversion_rate' => 1, 'local_currency_amount' => 300} 
		expected_hash_4 = {'report_id' => '121', 'currency' => 'INR', 'amount' => 1000, 'conversion_rate' => 4, 'local_currency_amount' => 4000}

    exp_rpt.populate_instance_data()

    actual_consolidated = exp_rpt.get_consolidated_expenses()
		puts actual_consolidated.to_s
		actual_consolidated.count.should ==4
		actual_consolidated.should include(expected_hash_1)
		actual_consolidated.should include(expected_hash_2)
		actual_consolidated.should include(expected_hash_3)
		actual_consolidated.should include(expected_hash_4)
		
	end

	it "should consolidate expenses by rpt and currency considering conversion rate from sharon sheet if no forex is available" do
		persisted_expenses  = [
								Expense.new(expense_rpt_id: '123',original_currency: 'EUR', original_cost:'200', cost_in_home_currency:'200',currency_conversion_rate:'1'),
								Expense.new(expense_rpt_id: '122',original_currency: 'EUR', original_cost:'100', cost_in_home_currency:'100',currency_conversion_rate:'1'),
								Expense.new(expense_rpt_id: '121',original_currency: 'INR', original_cost:'1000', cost_in_home_currency:'4000',currency_conversion_rate:'4'),
								Expense.new(expense_rpt_id: '121',original_currency: 'EUR', original_cost:'100', cost_in_home_currency:'100',currency_conversion_rate:'1'),
								Expense.new(expense_rpt_id: '121',original_currency: 'EUR', original_cost:'200', cost_in_home_currency:'200',currency_conversion_rate:'1')
							 ]

    Expense.stub(:find).and_return(persisted_expenses)
		exp_rpt = ExpenseSettlement.new(:expenses => ['somehashes'])
		expected_hash_1 = {'report_id' => '123', 'currency' => 'EUR', 'amount' => 200, 'conversion_rate' => 1, 'local_currency_amount' => 200}
		expected_hash_2 = {'report_id' => '122', 'currency' => 'EUR', 'amount' => 100, 'conversion_rate' => 1, 'local_currency_amount' => 100}
		expected_hash_3 = {'report_id' => '121', 'currency' => 'EUR', 'amount' => 300, 'conversion_rate' => 1, 'local_currency_amount' => 300}
		expected_hash_4 = {'report_id' => '121', 'currency' => 'INR', 'amount' => 1000, 'conversion_rate' => 4, 'local_currency_amount' => 4000}

    exp_rpt.populate_instance_data()

    actual_consolidated = exp_rpt.get_consolidated_expenses()
		puts actual_consolidated.to_s

		actual_consolidated.count.should ==4
		actual_consolidated.should include(expected_hash_1)
		actual_consolidated.should include(expected_hash_2)
		actual_consolidated.should include(expected_hash_3)
		actual_consolidated.should include(expected_hash_4)
	end

	it "should provide average forex rate for each currency" do
		forex_payments = [ForexPayment.new(:currency => 'EUR', :inr => 2000, :amount => 100), 
						ForexPayment.new(:currency => 'EUR', :inr => 1800, :amount => 100),
						ForexPayment.new(:currency => 'EUR', :inr => 950, :amount => 50),
						ForexPayment.new(:currency => 'USD', :inr => 1000, :amount => 100),
						ForexPayment.new(:currency => 'USD', :inr => 810, :amount => 90)]

		ForexPayment.stub!(:find).and_return(forex_payments)
		exp_rpt = ExpenseSettlement.new(:forex_payments => ['id1', 'id2'])
		exp_rpt.populate_forex_payments()
		actual_conv_rates = exp_rpt.get_conversion_rates_for_currency()
		actual_conv_rates.values.count == 2
		((actual_conv_rates["USD"]*100).round.to_f/100).should == (((1000+810).to_f/(100+90))*100).round.to_f/100
		((actual_conv_rates["EUR"]*100).round.to_f/100).should == (((2000+1800+950).to_f/(100+100+50))*100).round.to_f/100
	end

end

