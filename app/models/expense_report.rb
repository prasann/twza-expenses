class ExpenseReport
	include Mongoid::Document

	field :expenses, type: Array
	field :forex_payments, type: Array
	field :empl_id, type: String
	field :travel_id, type: String 


	def consolidated_expenses
		fetched_expenses = Expense.find(expenses)
		grpd_by_rpt_id = fetched_expenses.group_by{|expense|expense.expense_rpt_id}
		cnsltd_by_rptid_currency = grpd_by_rpt_id.values.collect do|expenses|
																grouped_by_currency = expenses.group_by{|expense|expense.original_currency}
																arr_rpt_id_expenses = consolidate_by_currency grouped_by_currency
																arr_rpt_id_expenses	
														 	end
		cnsltd_by_rptid_currency.flatten
	end

	def consolidate_by_currency(expenses_for_reportid)
		 expenses_for_reportid.values.collect do|expenses_by_cur|
											consolidated_exp = Hash.new
											consolidated_exp["amount"]=BigDecimal.new("0")
											expenses_by_cur.each do|expense_cur|
																	consolidated_exp["report_id"]=expense_cur.expense_rpt_id
																	consolidated_exp["currency"]=expense_cur.original_currency
																	consolidated_exp["amount"]=consolidated_exp["amount"]+BigDecimal.new(expense_cur.original_cost)
																	consolidated_exp["conversion_rate"]=1
																	consolidated_exp["local_currency_amount"]=consolidated_exp["amount"]*consolidated_exp["conversion_rate"]
																end
											consolidated_exp
											end
	end

end
