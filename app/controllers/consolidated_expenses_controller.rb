
class ConsolidatedExpensesController < ApplicationController

	HEADERS = ['Employee Id', 'Employee Name', 'Expense Report Id(s)', 'Account No', 'Amount']

	def index
		@reimbursable_expense_reports = get_reimbursable_expenses
		render :layout => 'tabs'
	end

	def export
		render_excel get_reimbursable_expenses()
	end

	def mark_processed_and_export
		render_excel get_reimbursable_expenses(true)	
	end

	private 
	def get_reimbursable_expenses(mark_as_closed = false)
		reimbursable_expense_reports = ExpenseSettlement.get_reimbursable_expense_reports(mark_as_closed)
		reimbursable_expense_reports.concat(ExpenseReimbursement.get_reimbursable_expense_reports(mark_as_closed))
	end

	def render_excel(reimbursable_expenses)
		respond_to do |format|
      		format.xls { send_data reimbursable_expenses.to_xls(:headers => HEADERS,
										   						:columns => [:empl_id, :empl_name, 
																			 :expense_report_ids, :bank_account_no, 
																			 :reimbursable_amount]),
								   :filename => "BankInstruction_#{Date.today.strftime('%d-%b-%Y')}.xls"
						}
		end
	end
end
