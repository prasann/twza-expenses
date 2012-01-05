require 'mongoid'

class ExpenseReportController < ApplicationController
  
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
			@expenses = Expense.fetch_for travel.emp_id, travel.departure_date, travel.return_date
			#@forex = Forex.fetch_for travel.emp_id, travel.departure_date, travel.return_date 
		end
	end
end
