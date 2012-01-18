require 'mongoid'

class ExpenseSettlement
	include Mongoid::Document
	include Mongoid::Timestamps

	field :expenses, type: Array
	field :forex_payments, type: Array
	field :empl_id, type: String
	 
	field :cash_handover, type: Float
	field :status, type: String

	belongs_to :outbound_travel
										
	def populate_instance_data
		populate_forex_payments
		populate_consolidated_expenses
	end
	
	def populate_consolidated_expenses
		@consolidated_expenses = []
		if(expenses && !expenses.empty?)
			expenses_detailed = Expense.find(expenses)
			
			grpd_by_rpt_id = expenses_detailed.group_by{|expense|expense.expense_rpt_id}
			@consolidated_expenses = grpd_by_rpt_id.values.collect do|expenses|
																	grouped_by_currency = expenses.group_by{|expense|expense.original_currency}
																	arr_rpt_id_expenses = consolidate_by_currency grouped_by_currency
																	arr_rpt_id_expenses
															 	end
		end
		@consolidated_expenses.flatten!
	end

	def consolidate_by_currency(expenses_by_reportid_hash)
		conversion_rate_hash=get_conversion_rates_for_currency()
		expense_values = expenses_by_reportid_hash.values
		expense_values.collect do|expenses_by_cur|
								con_exp = Hash.new
								con_exp["amount"]=BigDecimal.new("0")
								expenses_by_cur.each do|expense_cur|
													con_exp["report_id"]=expense_cur.expense_rpt_id
													con_exp["currency"]=expense_cur.original_currency
													con_exp["amount"]=con_exp["amount"]+BigDecimal.new(expense_cur.original_cost)
													con_exp["conversion_rate"]=get_conversion_rate_for(expense_cur)
													con_exp["local_currency_amount"]=con_exp["amount"]*con_exp["conversion_rate"]
												end
								con_exp
							end
	end

	def get_conversion_rates_for_currency
		relevant_forex = get_forex_payments
		@conversion_rates = relevant_forex.group_by(&:currency)
		@conversion_rates.collect do |currency,forexes|
			inr_sum = 0
			original_amount_sum = 0
			forexes.each do |forex|
				inr_sum += forex.inr.to_f
				original_amount_sum += forex.amount
			end
			@conversion_rates[currency] = inr_sum/original_amount_sum
		end
		@conversion_rates
	end
 			
	def populate_forex_payments
		@consolidated_forex = (forex_payments && !forex_payments.empty?) ? ForexPayment.find(forex_payments) : []
	end

	def get_conversion_rate
		(@conversion_rates && !@conversion_rates.empty?) ? @conversion_rates.values.first : 0
	end

	def get_conversion_rate_for(expense_currency)
    	@conversion_rates[expense_currency.original_currency]||(expense_currency.cost_in_home_currency.to_f/expense_currency.original_cost.to_f)
	end

	def get_receivable_amount
		all_expenses = @consolidated_expenses
		all_forex = get_forex_payments
		expense_inr_amount = 0
		forex_inr_amount = 0
		all_expenses.each{|expense|	expense_inr_amount += expense["local_currency_amount"]}
		all_forex.each{|forex|forex_inr_amount += forex.inr}
		forex_inr_amount-(expense_inr_amount+cash_handover*get_conversion_rate)
	end

  def get_forex_payments
  	@consolidated_forex
  end

  def get_consolidated_expenses
  	@consolidated_expenses
  end
end
