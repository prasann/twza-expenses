require 'mongoid'

class ExpenseReportController < ApplicationController
  
	def fetch
		converted_empl_id = "EMP" + params[:id].to_s
		@expenses = Expense.where(empl_id: converted_empl_id).to_a
		render 'list'
  	end

end
