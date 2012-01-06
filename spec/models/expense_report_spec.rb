require 'spec_helper'

describe 'expense_report' do

	it "should consolidate expenses by rpt and currency" do
		persisted_expenses  = [
								Expense.new(expense_rpt_id: '123',original_currency: 'EUR', original_cost:'200'),
								Expense.new(expense_rpt_id: '122',original_currency: 'EUR', original_cost:'100'),
								Expense.new(expense_rpt_id: '121',original_currency: 'INR', original_cost:'1000'),
								Expense.new(expense_rpt_id: '121',original_currency: 'EUR', original_cost:'100'),
								Expense.new(expense_rpt_id: '121',original_currency: 'EUR', original_cost:'200')
							 ]
		Expense.stub(:find).and_return(persisted_expenses)
		exp_rpt = ExpenseReport.new(:expenses => ['somehashes'])
		expected_hash_1 = {'report_id' => '123', 'currency' => 'EUR', 'amount' => 200, 'conversion_rate' => 1, 'local_currency_amount' => 200} 
		expected_hash_2 = {'report_id' => '122', 'currency' => 'EUR', 'amount' => 100, 'conversion_rate' => 1, 'local_currency_amount' => 100} 
		expected_hash_3 = {'report_id' => '121', 'currency' => 'EUR', 'amount' => 300, 'conversion_rate' => 1, 'local_currency_amount' => 300} 
		expected_hash_4 = {'report_id' => '121', 'currency' => 'INR', 'amount' => 1000, 'conversion_rate' => 1, 'local_currency_amount' => 1000} 
		actual_consolidated = exp_rpt.consolidated_expenses
		puts actual_consolidated.to_s
		actual_consolidated.count.should ==4
		actual_consolidated.should include(expected_hash_1)
		actual_consolidated.should include(expected_hash_2)
		actual_consolidated.should include(expected_hash_3)
		actual_consolidated.should include(expected_hash_4)
		
	end

end

