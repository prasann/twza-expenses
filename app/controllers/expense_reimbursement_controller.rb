class ExpenseReimbursementController < ApplicationController

	def filter
		if(params[:emp_id])
			@expense_reimbursements=ExpenseReimbursement.any_of({empl_id: params[:emp_id]},
																	 {status: params[:status]}).to_a
			expenses_from_travel = ExpenseSettlement.where(empl_id: params[:emp_id]).to_a
													.collect{|settlement| settlement.expenses}
													.flatten
			processed_expenses = @expense_reimbursements.collect{|reimbursement|reimbursement.expenses}.flatten.push(expenses_from_travel).flatten
			unprocessed_expenses = Expense.where(empl_id: 'EMP' + params[:emp_id].to_s).not_in(_id: processed_expenses).to_a.group_by(&:expense_rpt_id)
			unprocessed_expenses.each do|expense_report_id, expenses|
				if(!expenses.empty?)
					@expense_reimbursements.push(ExpenseReimbursement.new(:expense_report_id => expense_report_id, 
																	   :expenses => expenses.collect(&:id),
																	   :empl_id => params[:emp_id],
																	   :status => 'Unprocessed',
																	   :submitted_on=> expenses.first.report_submitted_at,
																	   :total_amount => expenses.sum{|expense|expense.original_cost.to_f}))
				end
			end

		end
		render 'index'
	end
end
