class ExpenseReport
	include Mongoid::Document

	field :expenses, type: Array
	field :forex_payments, type: Array
	field :empl_id, type: String
	field :travel_id, type: String 


	def consolidated_expenses
		expenses_detailed = Expense.find(expenses)
		
		grpd_by_rpt_id = expenses_detailed.group_by{|expense|expense.expense_rpt_id}
		cnsltd_by_rptid_currency = grpd_by_rpt_id.values.collect do|expenses|
																grouped_by_currency = expenses.group_by{|expense|expense.original_currency}
																arr_rpt_id_expenses = consolidate_by_currency grouped_by_currency
																arr_rpt_id_expenses
														 	end
		cnsltd_by_rptid_currency.flatten
	end

	def consolidate_by_currency(expenses_for_reportid)
		conversion_rate_hash=get_conversion_rates_for_currency()
		expenses_for_reportid.values.collect do|expenses_by_cur|
											con_exp = Hash.new
											con_exp["amount"]=BigDecimal.new("0")
											expenses_by_cur.each do|expense_cur|
																con_exp["report_id"]=expense_cur.expense_rpt_id
																con_exp["currency"]=expense_cur.original_currency
																con_exp["amount"]=con_exp["amount"]+BigDecimal.new(expense_cur.original_cost)
																con_exp["conversion_rate"]=conversion_rate_hash[con_exp["currency"]]||1
																con_exp["local_currency_amount"]=con_exp["amount"]*con_exp["conversion_rate"]
															end
											con_exp
											end
	end

	def get_conversion_rates_for_currency()
		relevant_forex = get_forex_payments
		conversion_rates = relevant_forex.group_by(&:currency)
		conversion_rates.collect do |currency,forexes|
			conversion_rates[currency] = (((forexes.sum { |forex| (forex.inr.to_f / forex.amount)}) / forexes.count)*100).round.to_f/100
		end
		conversion_rates
	end

	def get_forex_payments
		ForexPayment.find(forex_payments)
	end

end
