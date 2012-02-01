class ExpensesController < ApplicationController
  def index
    if (params[:id])
      @expenses = Expense.for_empl_id(params[:id])
    elsif (params[:report_id])
      @expenses = Expense.for_expense_report_id(params[:report_id])
    end
  end
end
