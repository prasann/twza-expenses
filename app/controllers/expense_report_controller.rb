require 'mongoid'

class ExpenseReportController < ApplicationController
  
	def fetch
		empid = params[:empl_id]
		if(empid)
			converted_empl_id = "EMP" + empid
			@expenses = Expense.where(empl_id: converted_empl_id).to_a
		end
		render 'list'
  	end

end
