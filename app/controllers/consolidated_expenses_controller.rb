class ConsolidatedExpensesController < ApplicationController
  include ExcelDataExporter

  HEADERS = ['Employee Id', 'Name', 'Bank A/C No', 'Cost In Home Currency', 'Deduction','Amount Payable After Deduction', 'Advance', 'Net Payable', 'Expense Report IDs' ,'Created By','Created At']
  COLUMNS = [:empl_id, :empl_name, :bank_account_no, :cost_in_home_currency, :deductions, :cost_in_home_currency, :advance, :reimbursable_amount, :expense_report_ids, :created_by, :created_at]

  def index
    @reimbursable_expense_reports = get_reimbursable_expenses
  end

  # TODO: Merge into the index method - based on the request format (which is already 'xls)
  def export
    render_excel(get_reimbursable_expenses)
  rescue => e
    redirect_to(consolidated_expenses_path, :flash => {:error => 'Could not fetch records'})
  end

  # TODO: Merge into the index method - based on the request format (which is already 'xls)
  def mark_processed_and_export
    completed_travel_reimbursements = ExpenseSettlement.mark_all_as_complete(params[:travel_reimbursements])
    completed_nontravel_reimbursements = ExpenseReimbursement.mark_all_as_complete(params[:nontravel_reimbursements])
    render_excel(completed_travel_reimbursements.concat(completed_nontravel_reimbursements))
  rescue => e
    logger.error "exception in excel export: " + e.inspect
    redirect_to(consolidated_expenses_path, :flash => {:error => 'Could not fetch records'})
  end

  private
  def get_reimbursable_expenses(mark_as_closed = false)
    reimbursable_expense_reports = ExpenseSettlement.get_reimbursable_expense_reports(mark_as_closed)
    reimbursable_expense_reports.concat(ExpenseReimbursement.get_reimbursable_expense_reports(mark_as_closed))
  end

  def render_excel(reimbursable_expenses)
    export_xls(reimbursable_expenses, HEADERS, {
      :exportable_fields => COLUMNS,
      :filename_prefix => "BankInstruction"
    })
  end
end
