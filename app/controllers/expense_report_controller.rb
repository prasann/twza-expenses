require 'mongoid'

class ExpenseReportController < ApplicationController
    FOREX_PAYMENT_DATES_PADDED_BY=15
	EXPENSE_DATES_PADDED_BY=5
	def list
		if(params[:id])
			converted_empl_id = "EMP" + params[:id]
			@expenses = Expense.where(empl_id: converted_empl_id).to_a
		end
	end

	def load_by_travel
		travel_id = params[:id]
		if(travel_id)
			travel = OutboundTravel.find(travel_id)
			expenses_from_date = travel.departure_date - EXPENSE_DATES_PADDED_BY
			expenses_to_date = travel.return_date + EXPENSE_DATES_PADDED_BY
			forex_from_date = travel.departure_date - FOREX_PAYMENT_DATES_PADDED_BY
			forex_to_date = travel.return_date + FOREX_PAYMENT_DATES_PADDED_BY

			processed_expenses = ExpenseReport.where(empl_id:travel.emp_id.to_s, processed: true).only(:expenses).to_a
			processed_expense_ids = processed_expenses.collect{|expense_rpt|expense_rpt.expenses}.flatten
			expenses = Expense.fetch_for travel.emp_id,expenses_from_date,expenses_to_date,processed_expense_ids 
			forex_payments = ForexPayment.fetch_for travel.emp_id,forex_from_date,forex_to_date
			@expense_report = ExpenseReport.new(:expenses => expenses, 
												:forex_payments => forex_payments, 
												:empl_id => travel.emp_id,
												:travel_id => travel.id.to_s)
		end
	end

	def generate_report
		@expense_report = ExpenseReport.new
		@expense_report.expenses = params[:expenses]
		@expense_report.cash_handover = params[:cash_handover].to_i
		@expense_report.forex_payments = params[:forex_payments]
		@expense_report.empl_id = params[:empl_id]
		@expense_report.travel_id = params[:travel_id]
		@expense_report.processed = false
		@expense_report.save
	end

	def set_processed
		expense_report = ExpenseReport.find(params[:id])
		expense_report.processed = true
		expense_report.save
		redirect_to outbound_travels_path
	end
end
